use crate::model::Model;
use ratatui::{
    layout::{Constraint, Direction, Layout, Rect},
    style::{Color, Modifier, Style},
    text::{Line, Span},
    widgets::{Block, Padding, Paragraph, Wrap},
    Frame,
};

pub fn render(f: &mut Frame, app: &mut Model) {
    let input_lines = app.input.lines().count().clamp(1, 3) as u16;
    let input_height = input_lines + 2;

    let chunks = Layout::default()
        .direction(Direction::Vertical)
        .constraints([
            Constraint::Length(3),
            Constraint::Min(5),
            Constraint::Length(input_height),
            Constraint::Length(2),
        ])
        .split(f.area());

    app.chat_area_y = chunks[1].y;
    app.chat_area_height = chunks[1].height;

    render_header(f, app, chunks[0]);
    render_chat(f, app, chunks[1]);
    render_input(f, app, chunks[2]);
    render_help(f, chunks[3]);
}

fn render_header(f: &mut Frame, app: &Model, area: Rect) {
    let copied_preview = app.copied_message.as_ref().map(|msg| {
        if msg.len() > 30 {
            format!("  📋 {}...", &msg[..30])
        } else {
            format!("  📋 {}", msg)
        }
    });

    let mut spans = vec![
        Span::raw("  "),
        Span::styled("🐠 ", Style::default()),
        Span::styled(
            "Babelfish",
            Style::default()
                .fg(Color::Cyan)
                .add_modifier(Modifier::BOLD),
        ),
        Span::raw("  "),
    ];

    for (i, pair) in app.pairs.iter().enumerate() {
        if i > 0 {
            spans.push(Span::raw("  "));
        }
        if i == app.current_pair_idx {
            spans.push(Span::styled(
                &pair.label,
                Style::default()
                    .fg(Color::Yellow)
                    .add_modifier(Modifier::BOLD),
            ));
        } else {
            spans.push(Span::styled(
                &pair.label,
                Style::default().fg(Color::Rgb(100, 100, 100)),
            ));
        }
    }

    if app.translating {
        spans.push(Span::styled(
            "  ⏳ Translating...",
            Style::default().fg(Color::Cyan),
        ));
    }

    if let Some(ref preview) = copied_preview {
        spans.push(Span::styled(preview, Style::default().fg(Color::Green)));
    }

    let header =
        Paragraph::new(Line::from(spans)).block(Block::default().padding(Padding::vertical(1)));
    f.render_widget(header, area);
}

fn render_chat(f: &mut Frame, app: &Model, area: Rect) {
    let mut lines = Vec::new();

    for (i, msg) in app.messages.iter().enumerate() {
        if i % 2 == 0 {
            let hr_width = area.width.saturating_sub(6).max(10) as usize;
            let hr = "─".repeat(hr_width);
            lines.push(Line::from(vec![
                Span::raw("  "),
                Span::styled("You", Style::default().fg(Color::Rgb(214, 157, 133))),
                Span::raw(" "),
                Span::styled(hr, Style::default().fg(Color::Rgb(80, 80, 80))),
            ]));
            lines.push(Line::from(""));

            for line in msg.lines() {
                lines.push(Line::from(vec![Span::raw("  "), Span::raw(line)]));
            }
            lines.push(Line::from(""));
        } else {
            let is_copied = app.copied_index == Some(i);
            let hr_width = area.width.saturating_sub(14).max(10) as usize;
            let hr = "─".repeat(hr_width);
            lines.push(Line::from(vec![
                Span::raw("  "),
                Span::styled("Translation", Style::default().fg(Color::Cyan)),
                Span::raw(" "),
                Span::styled(hr, Style::default().fg(Color::Rgb(80, 80, 80))),
            ]));
            lines.push(Line::from(""));

            for line in msg.lines() {
                let style = if is_copied {
                    Style::default().bg(Color::Rgb(40, 60, 40))
                } else {
                    Style::default()
                };
                lines.push(Line::from(vec![Span::raw("  "), Span::styled(line, style)]));
            }
            lines.push(Line::from(""));
        }
    }

    let chat = Paragraph::new(lines)
        .wrap(Wrap { trim: false })
        .scroll((app.scroll, 0));

    f.render_widget(chat, area);
}

fn render_input(f: &mut Frame, app: &Model, area: Rect) {
    let lines: Vec<&str> = app.input.lines().collect();
    let total_lines = lines.len().max(1);
    let start_line = total_lines.saturating_sub(3);
    let visible_lines = &lines[start_line..];

    let display_lines = if app.input.is_empty() {
        vec![Line::from(vec![
            Span::raw(" "),
            Span::styled("│", Style::default().fg(Color::Rgb(100, 100, 100))),
            Span::raw(" "),
            Span::styled(
                "Type your text here...",
                Style::default().fg(Color::Rgb(100, 100, 100)),
            ),
        ])]
    } else {
        visible_lines
            .iter()
            .map(|line| {
                Line::from(vec![
                    Span::raw(" "),
                    Span::styled("│", Style::default().fg(Color::Cyan)),
                    Span::raw(" "),
                    Span::styled(*line, Style::default().fg(Color::White)),
                ])
            })
            .collect()
    };

    let input = Paragraph::new(display_lines).block(Block::default().padding(Padding::vertical(1)));
    f.render_widget(input, area);

    let last_line = if app.input.is_empty() {
        ""
    } else {
        visible_lines.last().unwrap_or(&"")
    };
    let cursor_y = area.y + 1 + (visible_lines.len().saturating_sub(1)) as u16;
    f.set_cursor_position((area.x + 3 + last_line.len() as u16, cursor_y));
}

fn render_help(f: &mut Frame, area: Rect) {
    let light_grey = Color::Rgb(70, 70, 70);
    let help = Paragraph::new(Line::from(vec![
        Span::raw("  "),
        // Span::styled("Enter:", Style::default().fg(light_grey)),
        // Span::raw(" translate  "),
        Span::styled("Tab:", Style::default().fg(light_grey)),
        Span::raw(" switch pair  "),
        Span::styled("Ctrl+L:", Style::default().fg(light_grey)),
        Span::raw(" clear  "),
        Span::styled("Ctrl+C:", Style::default().fg(light_grey)),
        Span::raw(" quit"),
    ]))
    .style(Style::default().fg(Color::Rgb(120, 120, 120)));
    f.render_widget(help, area);
}
