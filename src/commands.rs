use crate::model::LanguagePair;
use crate::translator;
use anyhow::Result;
use std::sync::RwLock;
use std::fs;
use std::path::PathBuf;
use tauri::State;

pub struct AppState {
    pub api_key: RwLock<String>,
    pub pairs: Vec<LanguagePair>,
}

fn get_config_path() -> PathBuf {
    let config_dir = dirs::config_dir()
        .unwrap_or_else(|| PathBuf::from("."))
        .join("babelfish");

    fs::create_dir_all(&config_dir).ok();
    config_dir.join("config.json")
}

pub fn load_api_key() -> String {
    let config_path = get_config_path();

    if let Ok(content) = fs::read_to_string(&config_path) {
        if let Ok(json) = serde_json::from_str::<serde_json::Value>(&content) {
            return json.get("api_key")
                .and_then(|v| v.as_str())
                .unwrap_or("")
                .to_string();
        }
    }

    String::new()
}

fn save_api_key(key: &str) -> Result<(), std::io::Error> {
    let config_path = get_config_path();
    let json = serde_json::json!({
        "api_key": key
    });
    fs::write(&config_path, serde_json::to_string_pretty(&json)?)
}

#[tauri::command]
pub async fn translate(
    state: State<'_, AppState>,
    pair_name: String,
    text: String,
) -> Result<String, String> {
    let api_key = state.api_key.read().unwrap().clone();
    
    if api_key.is_empty() {
        return Err("API key not set".to_string());
    }

    let pair = state
        .pairs
        .iter()
        .find(|p| p.name == pair_name)
        .ok_or_else(|| "Language pair not found".to_string())?;

    translator::translate(&api_key, pair, &text)
        .await
        .map_err(|e| e.to_string())
}

#[tauri::command]
pub fn get_language_pairs(state: State<'_, AppState>) -> Vec<LanguagePair> {
    state.pairs.clone()
}

#[tauri::command]
pub async fn set_api_key(state: State<'_, AppState>, key: String) -> Result<(), String> {
    // Save to config file
    save_api_key(&key).map_err(|e| format!("Failed to save API key: {}", e))?;

    // Update in-memory state
    let mut api_key = state.api_key.write().unwrap();
    *api_key = key;
    Ok(())
}

#[tauri::command]
pub fn get_api_key(state: State<'_, AppState>) -> String {
    state.api_key.read().unwrap().clone()
}
