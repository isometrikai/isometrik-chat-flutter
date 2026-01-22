# Architectural Diagrams

**Last Updated:** January 21, 2026

This document contains visual architectural diagrams for the Isometrik Chat Flutter SDK. These diagrams use Mermaid syntax and can be rendered in most modern markdown viewers (GitHub, GitLab, VS Code with Mermaid extension, etc.).

## Table of Contents

1. [System Architecture Overview](#1-system-architecture-overview)
2. [Component Relationship Diagram](#2-component-relationship-diagram)
3. [Data Flow - Message Sending](#3-data-flow---message-sending)
4. [Data Flow - Message Receiving](#4-data-flow---message-receiving)
5. [Module Dependencies](#5-module-dependencies)
6. [Controller Composition](#6-controller-composition-mixin-pattern)
7. [Request/Response Flow](#7-requestresponse-flow)
8. [MQTT Event Processing Flow](#8-mqtt-event-processing-flow)
9. [Layered Architecture Detail](#9-layered-architecture-detail)
10. [State Management Flow](#10-state-management-flow)

---

## 1. System Architecture Overview

This diagram shows the high-level architecture of the SDK, including all major layers and their relationships.

```mermaid
graph TB
    subgraph "Application Layer"
        APP[Flutter App]
    end
    
    subgraph "SDK Public API"
        ISMCHAT[IsmChat<br/>Main Entry Point]
        DELEGATE[IsmChatDelegate<br/>Implementation]
    end
    
    subgraph "Presentation Layer"
        VIEWS[Views<br/>UI Screens]
        WIDGETS[Widgets<br/>Reusable Components]
    end
    
    subgraph "Controller Layer"
        CP_CTRL[ChatPageController<br/>25 Mixins]
        CONV_CTRL[ConversationsController<br/>15 Mixins]
        MQTT_CTRL[MqttController<br/>13 Mixins]
        COMMON_CTRL[CommonController]
    end
    
    subgraph "Business Logic Layer"
        VM[ViewModels]
        UTILS[Utilities]
    end
    
    subgraph "Data Layer"
        REPO[Repositories]
        API[ChatApi<br/>REST API]
        DB[DbWrapper<br/>SQLite]
    end
    
    subgraph "External Services"
        MQTT_BROKER[MQTT Broker]
        REST_API[REST API Server]
    end
    
    APP --> ISMCHAT
    ISMCHAT --> DELEGATE
    ISMCHAT --> VIEWS
    VIEWS --> CP_CTRL
    VIEWS --> CONV_CTRL
    VIEWS --> COMMON_CTRL
    CP_CTRL --> VM
    CONV_CTRL --> VM
    VM --> REPO
    REPO --> API
    REPO --> DB
    MQTT_CTRL --> MQTT_BROKER
    API --> REST_API
    MQTT_BROKER --> MQTT_CTRL
```

**Key Points:**
- Clear separation of concerns across layers
- Controllers use mixins for composition
- Data layer abstracts API and database access
- MQTT provides real-time communication

---

## 2. Component Relationship Diagram

This diagram shows how the main SDK components relate to each other and their internal composition.

```mermaid
graph LR
    subgraph "IsmChat Class"
        IC[IsmChat]
        IC --> IC_MIXINS[11 Mixins]
        IC_MIXINS --> IC_INIT[Initialization]
        IC_MIXINS --> IC_PROPS[Properties]
        IC_MIXINS --> IC_MQTT[MQTT Operations]
        IC_MIXINS --> IC_UI[UI Operations]
        IC_MIXINS --> IC_CONV[Conversation Ops]
        IC_MIXINS --> IC_USER[User Operations]
        IC_MIXINS --> IC_MSG[Message Operations]
        IC_MIXINS --> IC_NAV[Navigation Ops]
        IC_MIXINS --> IC_NOTIF[Notification Ops]
        IC_MIXINS --> IC_CLEAN[Cleanup Ops]
        IC_MIXINS --> IC_UPDATE[Update Operations]
    end
    
    subgraph "IsmChatDelegate"
        DEL[IsmChatDelegate]
        DEL --> DEL_MIXINS[9 Mixins]
    end
    
    subgraph "Controllers"
        CP[ChatPageController<br/>25 Mixins]
        CONV[ConversationsController<br/>15 Mixins]
        MQTT[MqttController<br/>13 Mixins]
    end
    
    IC --> DEL
    IC --> CP
    IC --> CONV
    IC --> MQTT
```

**Key Points:**
- `IsmChat` composes 11 mixins for different operation types
- `IsmChatDelegate` handles implementation details
- Controllers use extensive mixin composition

---

## 3. Data Flow - Message Sending

This sequence diagram shows the complete flow when a user sends a message.

```mermaid
sequenceDiagram
    participant User
    participant View
    participant Controller
    participant ViewModel
    participant Repository
    participant API
    participant MQTT
    participant Database
    
    User->>View: Send Message
    View->>Controller: sendMessage()
    Controller->>ViewModel: getChatMessages()
    ViewModel->>Repository: sendMessage()
    Repository->>API: POST /chat/message
    API-->>Repository: Response
    Repository->>Database: Save Message
    Repository-->>ViewModel: Success
    ViewModel-->>Controller: Message Sent
    Controller->>MQTT: Publish Message
    MQTT-->>Controller: Event Received
    Controller->>View: Update UI
```

**Key Points:**
- Request flows through all layers
- Message is saved to database for offline support
- MQTT publishes for real-time delivery
- UI updates reactively

---

## 4. Data Flow - Message Receiving

This sequence diagram shows how incoming messages are processed.

```mermaid
sequenceDiagram
    participant MQTT
    participant MqttController
    participant EventProcessing
    participant MessageHandler
    participant Database
    participant ChatController
    participant View
    
    MQTT->>MqttController: onMqttEvent()
    MqttController->>EventProcessing: Process Event
    EventProcessing->>MessageHandler: handleMessage()
    MessageHandler->>Database: Save Message
    MessageHandler->>ChatController: Update State
    ChatController->>View: Update UI (Reactive)
    View->>User: Display Message
```

**Key Points:**
- MQTT events trigger processing
- Messages are saved to database
- State updates trigger reactive UI updates
- No manual UI refresh needed

---

## 5. Module Dependencies

This diagram shows dependencies between different modules.

```mermaid
graph TD
    subgraph "Core Modules"
        MODELS[Models]
        UTILS[Utilities]
    end
    
    subgraph "Data Layer"
        REPO[Repositories]
        API[API]
        DB[Database]
    end
    
    subgraph "Business Layer"
        VM[ViewModels]
        DELEGATE[Delegate]
    end
    
    subgraph "Controller Layer"
        CTRL[Controllers]
    end
    
    subgraph "Presentation Layer"
        VIEWS[Views]
        WIDGETS[Widgets]
    end
    
    VIEWS --> CTRL
    WIDGETS --> VIEWS
    CTRL --> VM
    CTRL --> MODELS
    VM --> REPO
    VM --> MODELS
    REPO --> API
    REPO --> DB
    REPO --> MODELS
    DELEGATE --> VM
    DELEGATE --> REPO
    CTRL --> UTILS
    VM --> UTILS
    REPO --> UTILS
```

**Key Points:**
- Clear dependency direction (top to bottom)
- Core modules (Models, Utilities) are shared
- No circular dependencies
- Clean separation of concerns

---

## 6. Controller Composition (Mixin Pattern)

This diagram shows how controllers use mixins for composition.

```mermaid
graph TB
    subgraph "ChatPageController"
        CPC[ChatPageController]
        CPC --> M1[SendMessageMixin]
        CPC --> M2[GetMessageMixin]
        CPC --> M3[UiStateManagementMixin]
        CPC --> M4[CameraOperationsMixin]
        CPC --> M5[MediaOperationsMixin]
        CPC --> M6[ScrollNavigationMixin]
        CPC --> M7[LifecycleMixin]
        CPC --> M8[ContactGroupOpsMixin]
        CPC --> M9[MessageOpsMixin]
        CPC --> M10[MessageManagementMixin]
        CPC --> M11[BlockUnblockMixin]
        CPC --> M12[OtherOpsMixin]
        CPC --> M13[VariablesMixin]
        CPC --> M14[+ 12 more mixins...]
    end
    
    subgraph "ConversationsController"
        CONVC[ConversationsController]
        CONVC --> C1[VariablesMixin]
        CONVC --> C2[LifecycleMixin]
        CONVC --> C3[ConnectivityMixin]
        CONVC --> C4[ScrollListenersMixin]
        CONVC --> C5[WidgetRenderingMixin]
        CONVC --> C6[ConversationOpsMixin]
        CONVC --> C7[ContactOpsMixin]
        CONVC --> C8[ForwardOpsMixin]
        CONVC --> C9[StoryOpsMixin]
        CONVC --> C10[+ 6 more mixins...]
    end
    
    subgraph "MqttController"
        MQTTC[MqttController]
        MQTTC --> Q1[VariablesMixin]
        MQTTC --> Q2[UtilitiesMixin]
        MQTTC --> Q3[EventProcessingMixin]
        MQTTC --> Q4[MessageHandlersMixin]
        MQTTC --> Q5[MessageStatusMixin]
        MQTTC --> Q6[TypingEventsMixin]
        MQTTC --> Q7[GroupOpsMixin]
        MQTTC --> Q8[ConversationOpsMixin]
        MQTTC --> Q9[ReactionsMixin]
        MQTTC --> Q10[BlockUnblockMixin]
        MQTTC --> Q11[BroadcastMixin]
        MQTTC --> Q12[ObserverOpsMixin]
        MQTTC --> Q13[CallsMixin]
    end
```

**Key Points:**
- Each controller composes multiple focused mixins
- Mixins follow Single Responsibility Principle
- Easy to add/remove functionality
- Clear organization by domain

---

## 7. Request/Response Flow

This diagram shows the request/response cycle for API calls.

```mermaid
graph LR
    subgraph "Client Side"
        A[User Action]
        B[Controller]
        C[ViewModel]
        D[Repository]
        E[API Wrapper]
    end
    
    subgraph "Network"
        F[HTTP Request]
        G[HTTP Response]
    end
    
    subgraph "Server Side"
        H[REST API]
        I[Database]
    end
    
    A --> B
    B --> C
    C --> D
    D --> E
    E --> F
    F --> H
    H --> I
    I --> H
    H --> G
    G --> E
    E --> D
    D --> C
    C --> B
    B --> A
```

**Key Points:**
- Clear request path through layers
- Response flows back through same layers
- Repository abstracts network details
- Error handling at each layer

---

## 8. MQTT Event Processing Flow

This diagram shows how MQTT events are processed and routed.

```mermaid
graph TB
    MQTT[MQTT Broker] --> EVENT[onMqttEvent]
    EVENT --> QUEUE{Event Queue}
    QUEUE --> PROCESS[Event Processing]
    PROCESS --> TYPE{Event Type}
    
    TYPE -->|Message| MSG[Message Handler]
    TYPE -->|Typing| TYPING[Typing Handler]
    TYPE -->|Status| STATUS[Status Handler]
    TYPE -->|Group| GROUP[Group Handler]
    TYPE -->|Reaction| REACTION[Reaction Handler]
    TYPE -->|Block| BLOCK[Block Handler]
    TYPE -->|Broadcast| BROADCAST[Broadcast Handler]
    TYPE -->|Call| CALL[Call Handler]
    
    MSG --> DB[(Database)]
    TYPING --> UI[Update UI]
    STATUS --> UI
    GROUP --> DB
    REACTION --> DB
    BLOCK --> DB
    BROADCAST --> DB
    CALL --> UI
    
    DB --> UI
```

**Key Points:**
- Events are queued for processing
- Event type determines handler
- Database updates for persistent events
- UI updates for real-time feedback

---

## 9. Layered Architecture Detail

This diagram provides detailed view of each layer and its components.

```mermaid
graph TB
    subgraph "Layer 1: Presentation"
        L1A[Views]
        L1B[Widgets]
        L1C[UI Components]
    end
    
    subgraph "Layer 2: Controller"
        L2A[GetX Controllers]
        L2B[State Management]
        L2C[Reactive Variables]
    end
    
    subgraph "Layer 3: Business Logic"
        L3A[ViewModels]
        L3B[Delegates]
        L3C[Utilities]
    end
    
    subgraph "Layer 4: Data Access"
        L4A[Repositories]
        L4B[API Client]
        L4C[Database]
    end
    
    subgraph "Layer 5: External"
        L5A[MQTT Broker]
        L5B[REST API]
        L5C[File Storage]
    end
    
    L1A --> L2A
    L1B --> L1A
    L1C --> L1A
    L2A --> L3A
    L2B --> L2A
    L2C --> L2A
    L3A --> L4A
    L3B --> L3A
    L3C --> L3A
    L4A --> L4B
    L4A --> L4C
    L4B --> L5B
    L4C --> L5C
    L2A --> L5A
```

**Key Points:**
- Five distinct layers
- Each layer has specific responsibilities
- Dependencies flow downward only
- External services at the bottom

---

## 10. State Management Flow

This diagram shows how GetX reactive state management works.

```mermaid
graph LR
    subgraph "State Source"
        A[User Action]
        B[API Response]
        C[MQTT Event]
        D[Database Update]
    end
    
    subgraph "Controller"
        E[GetX Controller]
        F[Reactive Variables<br/>.obs]
    end
    
    subgraph "UI"
        G[Obx Widget]
        H[GetBuilder]
        I[UI Update]
    end
    
    A --> E
    B --> E
    C --> E
    D --> E
    E --> F
    F --> G
    F --> H
    G --> I
    H --> I
```

**Key Points:**
- Multiple state sources
- Reactive variables (.obs) hold state
- UI widgets automatically update
- No manual setState() needed

---

## Rendering Diagrams

These diagrams use Mermaid syntax. To view them:

1. **GitHub/GitLab**: Automatically rendered in markdown files
2. **VS Code**: Install "Markdown Preview Mermaid Support" extension
3. **Online**: Use [Mermaid Live Editor](https://mermaid.live/)
4. **Documentation Sites**: Most support Mermaid natively

## Related Documentation

- [ARCHITECTURE.md](../ARCHITECTURE.md) - Complete architecture documentation
- [MODULE_CONTROLLERS.md](./MODULE_CONTROLLERS.md) - Controllers documentation
- [MODULE_DATA.md](./MODULE_DATA.md) - Data layer documentation

