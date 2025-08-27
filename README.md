# LiveSupportApp

A modern and user-friendly live support application for iOS. Built with SwiftUI and featuring real-time messaging with WebSocket integration.

## Features

### Core Features
- **Real-time Messaging**: Instant communication via WebSocket
- **Smart Chat Flow**: JSON-based dynamic conversation steps
- **Modern UI**: Native iOS design with SwiftUI
- **Connection Status**: Real-time connection status indicator

### Advanced Features
- **Rating System**: 5-star user experience rating
- **Feedback Collection**: User comments and feedback system
- **Auto Reconnection**: Automatic reconnect when connection drops
- **Clean Architecture**: Clean code structure with VIPER architecture

## User Flow

1. **Start Conversation**: Live support automatically starts when app opens
2. **Menu Selection**: Options like Return Process, Order Status, Product Guide
3. **Interactive Chat**: Dynamic steps based on user choices
4. **End Conversation**: Terminate conversation with "End Chat" button
5. **Experience Rating**: 5-star rating and feedback system
6. **Reconnection**: Start new conversation with "Reconnect" button

## Architecture

### VIPER Architecture
- **View**: SwiftUI-based user interface
- **Interactor**: Business logic and WebSocket management
- **Presenter**: Bridge between View and Interactor
- **Entity**: Data models (ChatMessage, ChatStep, ChatAction)
- **Router**: Navigation management

### Folder Structure
```
LiveSupportApp/
├── App/                    # Main application files
├── Core/                   # Core components
│   ├── Models/            # Data models
│   ├── Utils/             # Utility classes
│   └── WebSocket/         # WebSocket management
├── Modules/
│   └── LiveSupport/       # Live support module
│       ├── Entity/
│       ├── Interactor/
│       ├── Presenter/
│       ├── Router/
│       └── View/
│           └── Components/ # UI components
└── Resources/             # JSON files and assets
```

## Technical Details

### Requirements
- iOS 14.0+
- Xcode 12.0+
- Swift 5.0+

### Dependencies
- **SwiftUI**: Modern UI framework
- **Combine**: Reactive programming
- **Foundation**: Core iOS framework

### WebSocket
- **URL**: `wss://echo.websocket.org` (for testing purposes)
- **Format**: JSON-based message protocol
- **Auto Reconnection**: Automatic reconnection when connection drops

## Data Models

### ChatMessage
```swift
struct ChatMessage {
    let id: UUID
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    let step: ChatStep?
}
```

### ChatStep
```swift
struct ChatStep {
    let id: String
    let type: String
    let content: ChatContentWrapper?
    let action: String?
}
```

### ConversationRating
```swift
struct ConversationRating {
    let rating: Int        // 1-5 stars
    let feedback: String?  // User feedback
    let timestamp: Date
}
```

## UI Components

- **MessageBubble**: Chat message bubbles
- **ActionButton**: Interactive action buttons  
- **RatingView**: Star rating screen
- **ChatInputView**: Message input field

## Feature Status

### Completed Features
- [x] WebSocket connection
- [x] Real-time messaging
- [x] JSON-based chat flow
- [x] Rating system
- [x] Feedback collection
- [x] Auto reconnection
- [x] Connection status indicator
- [x] Modern SwiftUI design

## Installation

1. Clone the project
2. Open with Xcode
3. Run the app (⌘+R)

## Contact

For questions about this project, please contact furkankarakoc.

---

**LiveSupportApp** - Modern iOS Live Support Application
