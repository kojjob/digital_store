# Flash Messages System

This document outlines the production-ready flash messages system for the Digital Store application.

## Features

- **Accessible**: Properly configured with ARIA attributes for screen readers
- **Responsive**: Different positioning on mobile and desktop
- **Customizable**: Configure colors, icons, durations, and content 
- **Interactive**: Automatically dismisses after configurable timeouts with smooth animations
- **HTML Support**: Optional HTML content with proper sanitization
- **Action Links**: Supports adding links (like "Undo") to flash messages
- **AJAX Compatible**: Works with dynamically added flash messages through Turbo/AJAX

## Usage

### Basic Usage

```ruby
# In your controller
flash[:notice] = "Your changes have been saved."
flash[:error] = "Something went wrong."
```

### Using the Helper Methods (Recommended)

```ruby
# In your controller (with the FlashHelper included)
flash_message("Your changes have been saved.")
flash_message("Failed to save changes", type: :error)

# With HTML (escaped by default)
flash_message("<strong>Success!</strong> Item created.", escape: false)

# With custom timeout (in milliseconds)
flash_message("This will stay longer", timeout: 10000)

# With action link
flash_message_with_action(
  "Item deleted successfully",
  "Undo",
  undo_item_path(@item),
  type: :notice
)
```

## Flash Types

The system supports several flash types with appropriate styling:

| Type | Usage | Color |
|------|-------|-------|
| `:notice`, `:success` | Positive feedback | Green |
| `:alert`, `:error`, `:danger` | Errors or warnings requiring attention | Red |
| `:warning` | Important but not critical notifications | Amber |
| `:info` | General information | Blue |
| Other types | Fallback styling | Gray |

## JavaScript Controller

The Stimulus controller `flash_messages_controller.js` handles:

- Animating messages in and out
- Auto-dismissing after configurable timeouts
- Manual dismissal via close button
- Dynamic addition of new messages

## Customization

### Changing Default Timeouts

You can adjust the default timeout values in the Stimulus controller:

```javascript
static values = {
  baseDelay: { type: Number, default: 5000 },  // Default delay in ms
  staggerDelay: { type: Number, default: 200 } // Delay between msgs in ms
}
```

### Per-Message Timeouts

Each message can have its own timeout:

```ruby
flash_message("Important warning", type: :warning, timeout: 8000)
```

## Accessibility

The flash messages system is built with accessibility in mind:

- ARIA live region for screen reader announcements
- Proper labeling for close buttons
- Keyboard navigable
- Sufficient color contrast

## Troubleshooting

- If flash messages aren't appearing, ensure the partial is included in your layout
- For messages with HTML, make sure to set `escape: false`
- If messages don't auto-dismiss, check for JavaScript errors in the console
