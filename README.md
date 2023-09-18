# Transitions

![Pub Version](https://img.shields.io/pub/v/transitions)
![GitHub](https://img.shields.io/github/license/your-username/transitions)

The **Transitions** Flutter package provides a collection of custom page route transitions to enhance the user experience in your Flutter applications. These transitions offer visually appealing effects when navigating between screens.

## Key Features

- **Custom Page Route Transitions**: Implement visually engaging transitions for screen navigation.
- **Easy Integration**: Seamlessly incorporate custom transitions into your Flutter applications.
- **Enhanced User Experience**: Elevate the overall user experience with visually appealing effects.

## Getting Started

1. **Installation**: Add the `multi_value_listenable` package to your `pubspec.yaml`:

```yaml
dependencies:
  transitions: ^1.0.0  # Replace with the latest version
```

2. **Import**: Import the package in your Dart code

```dart
import 'package:transitions/transitions.dart';
```

## PanelTranstionPageRouteBuilder

The `PanelTranstionPageRouteBuilder` allows opening a specific page under a responsive animation with slide-up and slide-down interactions. It offers a highly customizable and visually appealing transition.

#### Parameters:

- `builder`: A required callback function that takes a `PanelTranstionController` as a parameter and returns a widget. This widget represents the content of the page that will be displayed with the transition.
- `settings`: A required `RouteSettings` object that provides information about the route, such as its name.
- `initialHeight`: An optional parameter that specifies the initial height of the page when it starts to transition. If not provided, it defaults to a reasonable height value.
- `maxHeight`: An optional parameter that defines the maximum height that the page can expand to during the transition. If not provided, it defaults to the device's full screen height.

Usage:

```dart
final route = PanelTranstionPageRouteBuilder(
  builder: (controller) => MyPanelScreen(controller: controller),
  settings: RouteSettings(name: 'myPanelRoute'),
  initialHeight: 150, // Optional: Set the initial height.
  maxHeight: 400,     // Optional: Set the maximum height.
);

Navigator.of(context).push(route);
```

## SwipablePanelTransitionPageRouteBuilder

The `SwipablePanelTransitionPageRouteBuilder` is used to create a route that enables a swipable panel transition in your Flutter application. This transition allows users to swipe a panel up or down to reveal or dismiss content, providing an interactive and engaging user experience.

#### Parameters:

- `builder`: A required callback function that takes a `SwipablePanelTransitionController` as its parameter and returns a widget. This widget represents the content of the swipable panel.
- `settings`: A required `RouteSettings` object that provides information about the route, such as its name.
- `initialHeight` (optional): The initial height of the swipable panel. If not specified, it defaults to a height of 50 logical pixels.

Usage:

```dart
final route = SwipablePanelTransitionPageRouteBuilder(
  builder: (controller) {
    return MySwipablePanelContent(controller: controller);
  },
  settings: RouteSettings(name: 'mySwipablePanelRoute'),
);

Navigator.of(context).push(route);
```

## SwipablePopUpTransitionPageRouteBuilder

The `SwipablePopUpTransitionPageRouteBuilder` is used to create a route that enables a swipable popup transition in your Flutter application. This transition allows users to swipe a popup up or down to reveal or dismiss content, providing an interactive and engaging user experience.

#### Parameters:

- `builder`: A required callback function that takes a `SwipablePopUpTransitionController` as its parameter and returns a widget. This widget represents the content of the swipable popup.
- `settings`: A required `RouteSettings` object that provides information about the route, such as its name.
- `initOffset` (optional): The initial offset for the popup. If not specified, it defaults to `Offset.zero`.

Usage:

```dart
final route = SwipablePopUpTransitionPageRouteBuilder(
  builder: (controller) {
    return MySwipablePopUpContent(controller: controller);
  },
  settings: RouteSettings(name: 'mySwipablePopUpRoute'),
);

Navigator.of(context).push(route);
```

## SlingUpPageRouteBuilder

The `SlingUpPageRouteBuilder` is used to navigate to a new view within the app's stack by sliding the view from bottom to top. This transition does not involve any user interactions and provides a smooth animation.

#### Parameters:

- `child`: A required parameter that specifies the widget to be rendered as the new view during the transition.
- `settings`: A required `RouteSettings` object that provides information about the route, such as its name.

Usage:

```dart
final route = SlingUpPageRouteBuilder(
  child: MySlingUpScreen(),
  settings: RouteSettings(name: 'mySlingUpRoute'),
);

Navigator.of(context).push(route);
```

## InstantTranstionPageRouteBuilder

The `InstantTranstionPageRouteBuilder` is a custom [PageRouteBuilder] that instantly renders the incoming view, providing a seamless transition with no animation delay.

#### Parameters:

- `child`: A required parameter that specifies the widget to be rendered as the new view during the transition.
- `settings`: A required `RouteSettings` object that provides information about the route, such as its name.

Usage:

```dart
final route = InstantTranstionPageRouteBuilder(
  child: MyScreen(),
  settings: RouteSettings(name: 'myRoute'),
);

Navigator.of(context).push(route);
```
