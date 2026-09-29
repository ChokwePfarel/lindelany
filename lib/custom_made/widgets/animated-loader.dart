import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class AnimatedLoadingDialogAlt extends StatefulWidget {
  final bool isSigning;

  const AnimatedLoadingDialogAlt({
    Key? key,
    required this.isSigning,
  }) : super(key: key);

  @override
  State<AnimatedLoadingDialogAlt> createState() => _AnimatedLoadingDialogAltState();
}

class _AnimatedLoadingDialogAltState extends State<AnimatedLoadingDialogAlt> {
  int _currentIndex = 0;
  bool _shouldShow = false; // Controls whether dialog is visible
  final List<String> _messages = [
    'Begun sign in',
    'setting up',
    'loading data'
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AnimatedLoadingDialogAlt oldWidget) {
    super.didUpdateWidget(oldWidget);

    // When isSigning becomes true, start the 4 second delay
    if (widget.isSigning && !oldWidget.isSigning) {
      _startDelayAndAnimation();
    }

    // When isSigning becomes false, reset everything
    if (!widget.isSigning && oldWidget.isSigning) {
      _reset();
    }
  }

  void _startDelayAndAnimation() async {
    // Reset state first
    setState(() {
      _shouldShow = false;
      _currentIndex = 0;
    });

    // Wait 4 seconds before showing the dialog
    await Future.delayed(const Duration(seconds: 4));

    if (mounted && widget.isSigning) {
      setState(() {
        _shouldShow = true;
      });
      _startAnimation();
    }
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && _shouldShow && widget.isSigning) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _messages.length;
        });
        _startAnimation(); // Continue the loop
      }
    });
  }

  void _reset() {
    setState(() {
      _shouldShow = false;
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything if isSigning is false OR we haven't waited 4 seconds yet
    if (!widget.isSigning || !_shouldShow) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.black26,
      child: Center(
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 600),
                  crossFadeState: _getCrossFadeState(),
                  firstChild: Text(
                    _messages[_currentIndex],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  secondChild: Text(
                    _messages[(_currentIndex + 1) % _messages.length],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                CircularProgressIndicator(
                  color: Colors.blue.shade900,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  CrossFadeState _getCrossFadeState() {
    return _currentIndex % 2 == 0
        ? CrossFadeState.showFirst
        : CrossFadeState.showSecond;
  }

  @override
  void dispose() {
    super.dispose();
  }
}