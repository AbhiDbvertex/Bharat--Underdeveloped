// import 'package:flutter/material.dart';
//
// class CustomButton extends StatefulWidget {
//   final String label;
//   final VoidCallback onPressed;
//   final double width;
//   final double height;
//   final Color color;
//   final Color textColor;
//   final double fontSize;
//
//   const CustomButton({
//     super.key,
//     required this.label,
//     required this.onPressed,
//     this.width = 300,
//     this.height = 50,
//     this.color = const Color(0xFF388E3C),
//     this.textColor = Colors.white,
//     this.fontSize = 18,
//   });
//
//   @override
//   State<CustomButton> createState() => _CustomButtonState();
// }
//
// class _CustomButtonState extends State<CustomButton> {
//   double _scale = 1.0;
//
//   void _onTapDown(TapDownDetails details) => setState(() => _scale = 0.95);
//   void _onTapUp(TapUpDetails details) {
//     setState(() => _scale = 1.0);
//     widget.onPressed();
//   }
//
//   void _onTapCancel() => setState(() => _scale = 1.0);
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTapDown: _onTapDown,
//       onTapUp: _onTapUp,
//       onTapCancel: _onTapCancel,
//       child: AnimatedScale(
//         scale: _scale,
//         duration: const Duration(milliseconds: 100),
//         child: Container(
//           width: widget.width,
//           height: widget.height,
//           decoration: BoxDecoration(
//             color: widget.color,
//             borderRadius: BorderRadius.circular(25),
//           ),
//           alignment: Alignment.center,
//           child: Text(
//             widget.label,
//             style: TextStyle(
//               color: widget.textColor,
//               fontSize: widget.fontSize,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final Color color;
  final Color textColor;
  final double fontSize;
  final bool isLoading; // NEW
  final bool enabled;   // NEW

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = 300,
    this.height = 50,
    this.color = const Color(0xFF388E3C),
    this.textColor = Colors.white,
    this.fontSize = 18,
    this.isLoading = false, // default: false
    this.enabled = true,    // default: true
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    if (widget.enabled && !widget.isLoading) {
      setState(() => _scale = 0.95);
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.enabled && !widget.isLoading) {
      setState(() => _scale = 1.0);
      widget.onPressed();
    }
  }

  void _onTapCancel() {
    if (widget.enabled && !widget.isLoading) {
      setState(() => _scale = 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Opacity(
          opacity: widget.enabled ? 1.0 : 0.6,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(25),
            ),
            alignment: Alignment.center,
            child: widget.isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Text(
              widget.label,
              style: TextStyle(
                color: widget.textColor,
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
