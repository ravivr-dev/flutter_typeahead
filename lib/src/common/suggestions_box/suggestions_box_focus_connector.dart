import 'package:flutter/material.dart';
import 'package:flutter_typeahead/src/common/suggestions_box/connector_widget.dart';
import 'package:flutter_typeahead/src/common/suggestions_box/suggestions_controller.dart';

/// Connects the suggestions box to the focus node of the child.
///
/// This is a two way connection:
/// * When the focus of the child changes, the suggestions box is opened or closed.
/// * When the suggestions box is opened, the focus is moved to the suggestions box.
class SuggestionsBoxFocusConnector<T> extends StatefulWidget {
  const SuggestionsBoxFocusConnector({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.child,
    this.hideOnUnfocus = true,
  });

  /// The controller of the suggestions box.
  final SuggestionsController<T> controller;

  /// The focus node of the child of the suggestions box.
  final FocusNode focusNode;

  /// The child of the suggestions box.
  final Widget child;

  /// Whether the suggestions box should be hidden when the focus is lost.
  final bool hideOnUnfocus;

  @override
  State<SuggestionsBoxFocusConnector<T>> createState() =>
      _SuggestionsBoxFocusConnectorState<T>();
}

class _SuggestionsBoxFocusConnectorState<T>
    extends State<SuggestionsBoxFocusConnector<T>> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.controller.resize();
      if (widget.focusNode.hasFocus) {
        widget.controller.open();
      }
    });
  }

  /// Handles when the state of the suggestions box changes.
  void onControllerChanged() {
    if (widget.controller.isOpen) {
      widget.focusNode.requestFocus();
    } else if (!widget.controller.retainFocus) {
      widget.focusNode.unfocus();
    }
  }

  /// Handles when the focus of the child of the suggestions box changes.
  void onFocusChanged() {
    if (widget.focusNode.hasFocus) {
      widget.controller.open();
    } else if (!widget.controller.focused) {
      if (widget.hideOnUnfocus) {
        widget.controller.close();
      }
    }
  }

  @override
  Widget build(BuildContext context) => ConnectorWidget(
        value: widget.focusNode,
        connect: (value) => value.addListener(onFocusChanged),
        disconnect: (value, key) => value.removeListener(onFocusChanged),
        child: ConnectorWidget(
          value: widget.controller,
          connect: (value) => value.addListener(onControllerChanged),
          disconnect: (value, key) => value.removeListener(onControllerChanged),
          child: widget.child,
        ),
      );
}
