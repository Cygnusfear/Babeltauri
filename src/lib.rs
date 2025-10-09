mod commands;
mod model;
mod prompts;
mod translator;

pub use commands::AppState;
pub use model::LanguagePair;

use std::sync::RwLock;

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    dotenvy::dotenv().ok();

    // Try to load from saved config first, fallback to env var
    let api_key = commands::load_api_key();
    let api_key = if api_key.is_empty() {
        std::env::var("OPENROUTER_API_KEY").unwrap_or_default()
    } else {
        api_key
    };
    
    let pairs = prompts::load_prompts().unwrap_or_else(|_| vec![
        LanguagePair::new("es-en".to_string(), include_str!("../prompts/es-en.md").to_string()),
        LanguagePair::new("pt-en".to_string(), include_str!("../prompts/pt-en.md").to_string()),
    ]);

    let state = AppState {
        api_key: RwLock::new(api_key),
        pairs,
    };

    tauri::Builder::default()
        .manage(state)
        .invoke_handler(tauri::generate_handler![
            commands::translate,
            commands::get_language_pairs,
            commands::set_api_key,
            commands::get_api_key,
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
