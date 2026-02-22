import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';
import '../../widgets/ocean/ocean_background.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  bool _isLoading = false;
  bool _showPasswordSection = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _usernameController = TextEditingController(text: user?.username ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.whiteCardTheme,
      child: OceanBackground(
        enableWave: true,
        enableParticles: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit, color: Color(0xFF1E8C93)),
                SizedBox(width: 10),
                Text('账户设置', style: TextStyle(color: Colors.black)),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 头像部分
                  WhiteCard(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0A1628), Color(0xFF15203B)],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFE8B84A),
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 50,
                            color: Color(0xFFE8B84A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '点击更换头像',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 基本信息
                  WhiteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text(
                            '基本信息',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: _usernameController,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: '用户名',
                            labelStyle: const TextStyle(color: Colors.black54),
                            prefixIcon: const Icon(Icons.person, color: Color(0xFF1E8C93)),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF1E8C93), width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入用户名';
                            }
                            if (value.length < 3) {
                              return '用户名至少3个字符';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.black),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: '邮箱',
                            labelStyle: const TextStyle(color: Colors.black54),
                            prefixIcon: const Icon(Icons.email, color: Color(0xFF1E8C93)),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF1E8C93), width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入邮箱';
                            }
                            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(value)) {
                              return '请输入有效的邮箱地址';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          style: const TextStyle(color: Colors.black),
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: '手机号',
                            labelStyle: const TextStyle(color: Colors.black54),
                            prefixIcon: const Icon(Icons.phone, color: Color(0xFF1E8C93)),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF1E8C93), width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 密码修改
                  WhiteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _showPasswordSection = !_showPasswordSection;
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '修改密码',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Icon(
                                _showPasswordSection ? Icons.expand_less : Icons.expand_more,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                        if (_showPasswordSection) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _oldPasswordController,
                            style: const TextStyle(color: Colors.black),
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: '当前密码',
                              labelStyle: const TextStyle(color: Colors.black54),
                              prefixIcon: const Icon(Icons.lock, color: Color(0xFF1E8C93)),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF1E8C93), width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _newPasswordController,
                            style: const TextStyle(color: Colors.black),
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: '新密码',
                              labelStyle: const TextStyle(color: Colors.black54),
                              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1E8C93)),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF1E8C93), width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (value.length < 6) {
                                  return '密码至少6个字符';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPasswordController,
                            style: const TextStyle(color: Colors.black),
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: '确认新密码',
                              labelStyle: const TextStyle(color: Colors.black54),
                              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1E8C93)),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF1E8C93), width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (_newPasswordController.text.isNotEmpty) {
                                if (value == null || value.isEmpty) {
                                  return '请确认密码';
                                }
                                if (value != _newPasswordController.text) {
                                  return '两次输入的密码不一致';
                                }
                              }
                              return null;
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 保存按钮
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8B84A),
                      foregroundColor: const Color(0xFF0A1628),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : _saveProfile,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0A1628)),
                          )
                        : const Text('保存修改', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authProvider).user;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 更新用户信息
      await _apiService.updateUser(
        user.id,
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      );

      // 如果填写了新密码，则修改密码
      if (_showPasswordSection &&
          _oldPasswordController.text.isNotEmpty &&
          _newPasswordController.text.isNotEmpty) {
        await _apiService.changePassword(
          user.id,
          _oldPasswordController.text,
          _newPasswordController.text,
        );
      }

      // 刷新用户信息
      final updatedUser = await _apiService.getCurrentUser();
      ref.read(authProvider.notifier).updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存成功')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存失败，请稍后重试')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
