use crate::model::LanguagePair;
use anyhow::{Context, Result};
use std::fs;
use std::path::PathBuf;

pub fn load_prompts() -> Result<Vec<LanguagePair>> {
    let mut pairs = Vec::new();
    let config_dir = get_config_dir()?;

    if config_dir.exists() {
        for entry in fs::read_dir(&config_dir)? {
            let entry = entry?;
            let path = entry.path();
            
            if path.extension().and_then(|s| s.to_str()) == Some("md") {
                if let Some(name) = path.file_stem().and_then(|s| s.to_str()) {
                    if name.eq_ignore_ascii_case("readme") {
                        continue;
                    }
                    let prompt = fs::read_to_string(&path)
                        .with_context(|| format!("Failed to read prompt: {:?}", path))?;
                    pairs.push(LanguagePair::new(name.to_string(), prompt.trim().to_string()));
                }
            }
        }
    }

    if pairs.is_empty() {
        load_default_prompts(&mut pairs, &config_dir)?;
    }

    pairs.sort_by(|a, b| a.name.cmp(&b.name));
    
    Ok(pairs)
}

fn get_config_dir() -> Result<PathBuf> {
    let home = std::env::var("HOME").context("HOME not set")?;
    Ok(PathBuf::from(home).join(".config/babelfish"))
}

fn load_default_prompts(pairs: &mut Vec<LanguagePair>, config_dir: &PathBuf) -> Result<()> {
    const ES_EN: &str = include_str!("../prompts/es-en.md");
    const PT_EN: &str = include_str!("../prompts/pt-en.md");

    pairs.push(LanguagePair::new("es_en".to_string(), ES_EN.trim().to_string()));
    pairs.push(LanguagePair::new("pt_en".to_string(), PT_EN.trim().to_string()));

    fs::create_dir_all(config_dir)?;
    fs::write(config_dir.join("es_en.md"), ES_EN)?;
    fs::write(config_dir.join("pt_en.md"), PT_EN)?;

    Ok(())
}
