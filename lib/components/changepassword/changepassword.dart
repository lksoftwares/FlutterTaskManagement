import 'package:flutter/material.dart';
import 'package:lktaskmanagementapp/packages/headerfiles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Changepassword extends StatefulWidget {
  const Changepassword({super.key});

  @override
  State<Changepassword> createState() => _ChangepasswordState();
}

class _ChangepasswordState extends State<Changepassword> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  final _formKey = GlobalKey<FormState>();
  String? _confirmPasswordError;

  void _validateConfirmPassword() {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _confirmPasswordError = "Passwords don't match";
      });
    } else {
      setState(() {
        _confirmPasswordError = null;
      });
    }
  }

  Future<void> changePassword() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_Id');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ID is not available')),
      );
      return;
    }

    final response = await new ApiService().request(
      method: 'post',
      endpoint: 'user/ChangePassword',
      body: {
        "oldPassword": _oldPasswordController.text,
        "newPassword": _newPasswordController.text,
        "confirmPassword": _confirmPasswordController.text,
        "userId": userId,
      },
    );
print(userId);
    if (response.isNotEmpty && response['statusCode'] == 200) {
      _showSuccessDialog(response['message'] ?? 'Password changed successfully');
    } else {
      showToast(
        msg: response['message'] ?? 'Failed',
      );
    }
  }
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 80),
              SizedBox(height: 10),
              Text(
                ' Success',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Your password has been changed successfully.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Change Password",
        onLogout: () => AuthService.logout(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 80.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Reset password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Divider(color: Colors.black),
                    SizedBox(height: 10),
                    CustomTextField(
                      controller: _oldPasswordController,
                      label: 'Old Password',
                      hintText: 'Enter your old password',
                      obscureText: _obscureOldPassword,
                      prefixIcon: Icon(Icons.lock),
                      maxLines: 1,
                      suffixIcon: Icon(
                        _obscureOldPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onSuffixIconPressed: () {
                        setState(() {
                          _obscureOldPassword = !_obscureOldPassword;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      controller: _newPasswordController,
                      label: 'New Password',
                      hintText: 'Enter your new password',
                      obscureText: _obscureNewPassword,
                      prefixIcon: Icon(Icons.lock),
                      maxLines: 1,

                      suffixIcon: Icon(
                        _obscureNewPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onSuffixIconPressed: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hintText: 'Confirm your password',
                      obscureText: _obscureConfirmPassword,
                      prefixIcon: Icon(Icons.lock),
                      maxLines: 1,

                      suffixIcon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onSuffixIconPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      onChanged: (value) {
                        _validateConfirmPassword();
                      },
                    ),
                    if (_confirmPasswordError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _confirmPasswordError!,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    SizedBox(height: 25),
                    CustomButton(
                      buttonText: 'Change Password',
                      onPressed: () {
                        if (_oldPasswordController.text.isEmpty ||
                            _newPasswordController.text.isEmpty ||
                            _confirmPasswordController.text.isEmpty) {
                          showToast(
                            msg: 'All fields are required',
                            backgroundColor: Colors.red,
                          );
                        } else if (_formKey.currentState?.validate() ?? false) {
                          changePassword();
                        }
                      },
                      color: primaryColor,
                      width: 290,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
