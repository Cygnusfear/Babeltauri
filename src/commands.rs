use crate::model::LanguagePair;
use crate::translator;
use anyhow::Result;
use std::sync::RwLock;
use tauri::State;

pub struct AppState {
    pub api_key: RwLock<String>,
    pub pairs: Vec<LanguagePair>,
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
    let mut api_key = state.api_key.write().unwrap();
    *api_key = key;
    Ok(())
}

#[tauri::command]
pub fn get_api_key(state: State<'_, AppState>) -> String {
    state.api_key.read().unwrap().clone()
}
