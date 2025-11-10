# 🎨 AppSnackBar - Standardized SnackBar Utility

## 📋 Overview
The `AppSnackBar` is a utility that provides consistent and standardized SnackBars throughout the MoodDot app.

## 🎯 Features
- **Consistent design** with standardized icons, colors, and formatting
- **Floating behavior** with rounded borders and elevation
- **Auto-cleanup** removes active SnackBars before showing new ones
- **Predefined types** for different contexts
- **Customization** for specific cases

## 🎨 Available Types

### 1. **Success** (Green)
```dart
AppSnackBar.showSuccess(context, 'Operation completed successfully!');
```

### 2. **Error** (Red)
```dart
AppSnackBar.showError(context, 'Error performing operation');
```

### 3. **Warning** (Orange)
```dart
AppSnackBar.showWarning(context, 'Warning: please check your data');
```

### 4. **Information** (Blue)
```dart
AppSnackBar.showInfo(context, 'New version available');
```

### 5. **Custom**
```dart
AppSnackBar.showCustom(
  context,
  message: 'Custom message',
  backgroundColor: Colors.purple,
  icon: Icons.star,
);
```

## 🎭 App-Specific Types

### **Intelligent System** (Purple)
```dart
AppSnackBar.showAISuccess(context, 'AI reset successfully!');
```

### **Notifications** (Indigo)
```dart
AppSnackBar.showNotificationSuccess(context, 'Notification sent!');
```

### **Mood Entries** (Purple)
```dart
AppSnackBar.showMoodSuccess(context, 'Mood registered successfully!');
```

## ⚙️ Optional Parameters

### **Duration**
```dart
AppSnackBar.showSuccess(
  context, 
  'Message', 
  duration: Duration(seconds: 5),
);
```

### **Action**
```dart
AppSnackBar.showError(
  context,
  'Error saving',
  action: SnackBarAction(
    label: 'TRY AGAIN',
    onPressed: () => retry(),
  ),
);
```

## 📱 Usage Examples in App

### **Add Mood Page**
```dart
// Success
AppSnackBar.showMoodSuccess(context, 'Mood registered successfully!');

// Error
AppSnackBar.showError(context, 'Error saving: $error');
```

### **Settings Page**
```dart
// Notification
AppSnackBar.showNotificationSuccess(context, 'Test notification sent!');

// AI System
AppSnackBar.showAISuccess(context, 'Intelligent system reset successfully!');
```

### **Home Page**
```dart
// Deletion
AppSnackBar.showSuccess(context, 'Record deleted successfully');
```

## 🎨 Design System

### **Visual Standards:**
- **Behavior**: Floating with 16px margin
- **Shape**: Rounded borders (12px)
- **Elevation**: 6px shadow
- **Icons**: 20px with contrasting colors
- **Text**: White, weight 500, size 14px
- **Default duration**: 3 seconds

### **System Colors:**
- 🟢 **Success**: `AppTheme.successColor`
- 🔴 **Error**: `AppTheme.errorColor`
- 🟠 **Warning**: `AppTheme.warningColor`
- 🔵 **Info**: `AppTheme.infoColor`
- 🟣 **AI**: `AppTheme.aiColor`
- 🟦 **Notifications**: `AppTheme.notificationColor`
- 🟪 **Mood**: `AppTheme.secondaryColor`

## 🔧 Migrating Existing Code

### **Before:**
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Message'),
    backgroundColor: Colors.green.shade600,
    behavior: SnackBarBehavior.floating,
  ),
);
```

### **After:**
```dart
AppSnackBar.showSuccess(context, 'Message');
```

## ✅ Benefits

- 🎨 **Visual consistency** throughout the app
- 🔧 **Simplified maintenance** - centralized changes
- 📱 **Improved UX** with standardized design
- ⚡ **Rapid development** with predefined methods
- 🎯 **Specific context** with types for different functionalities