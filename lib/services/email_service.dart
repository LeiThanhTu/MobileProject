import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmailService {
  static Future<bool> showPasswordResetDialog(
    BuildContext context,
    String tempPassword,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Mật khẩu tạm thời',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mật khẩu tạm thời của bạn là:',
                  style: GoogleFonts.poppins(),
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    tempPassword,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Vui lòng đổi mật khẩu sau khi đăng nhập.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.red[400],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Đóng dialog
                  Navigator.pop(context); // Quay lại màn hình đăng nhập
                },
                child: Text(
                  'Đóng',
                  style: GoogleFonts.poppins(
                    color: Colors.indigo,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
    return true;
  }
}
