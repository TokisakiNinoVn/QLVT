import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:flutter/services.dart';

import 'package:txng/services/production_facility/account_service.dart';
import 'package:txng/config/color_config.dart';

class CSSXAccountManagementScreen extends StatefulWidget {
  const CSSXAccountManagementScreen({super.key});

  @override
  State<CSSXAccountManagementScreen> createState() =>
      _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<CSSXAccountManagementScreen> {
  static final AccountService _accountService = AccountService();
  late List<Map<String, dynamic>> accounts = [];
  late List<Map<String, dynamic>> filteredAccounts = [];
  bool _isLoading = true;
  String _selectedRole = 'all';
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterAccounts();
    });
  }

  Future<void> _loadAccounts() async {
    try {
      final response = await _accountService.getAllAccounService();
      final rawData = response["data"]?["nhancongsanxuats"]?["data"];

      if (rawData is List) {
        setState(() {
          accounts =
              rawData
                  .map<Map<String, dynamic>>(
                    (item) => Map<String, dynamic>.from(item),
                  )
                  .toList();
          _filterAccounts();
        });
      } else {
        setState(() {
          accounts = [];
          filteredAccounts = [];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi khi tải dữ liệu: $e")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterAccounts() {
    final searchTerm = _searchController.text.toLowerCase();
    setState(() {
      if (_selectedRole == 'all') {
        filteredAccounts =
            accounts.where((account) {
              final name = account['hoten']?.toString().toLowerCase() ?? '';
              final phone =
                  account['sodienthoai']?.toString().toLowerCase() ?? '';
              return name.contains(searchTerm) || phone.contains(searchTerm);
            }).toList();
      } else {
        filteredAccounts =
            accounts.where((account) {
              final roleMatch = account['quyenhan'] == _selectedRole;
              if (!roleMatch) return false;
              final name = account['hoten']?.toString().toLowerCase() ?? '';
              final phone =
                  account['sodienthoai']?.toString().toLowerCase() ?? '';
              return name.contains(searchTerm) || phone.contains(searchTerm);
            }).toList();
      }
    });
  }

  Map<String, dynamic>? selectedAccount;

  void _showAccountDetails(Map<String, dynamic> account) {
    setState(() => selectedAccount = account);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => Dialog(
            insetPadding: const EdgeInsets.all(0),
            child: Scaffold(
              appBar: AppBar(
                title: const Text("Thông tin tài khoản"),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _showFullImage(account["avatar"]),
                      child: Hero(
                        tag: "avatar-${account['id']}",
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(
                            _checkAvatarLink(account["avatar"]),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._buildAccountInfoList(account),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            context.go(
                              "/account-management/account-edit/${account['id']}",
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text("Chỉnh sửa"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _confirmDelete(account),
                          icon: const Icon(Icons.delete),
                          label: const Text("Xóa"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.error,
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (_) => GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Scaffold(
              backgroundColor: Colors.black.withOpacity(0.9),
              body: Stack(
                children: [
                  Center(
                    child: Hero(
                      tag: "avatar-${selectedAccount?['id']}",
                      child: InteractiveViewer(child: Image.network(imageUrl)),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  List<Widget> _buildAccountInfoList(Map<String, dynamic> account) {
    final entries = {
      "Họ tên": [Icons.person, account["hoten"]],
      "Ngày sinh": [Icons.calendar_today, _formatDate(account["ngaysinh"])],
      "Địa chỉ": [Icons.location_on, account["diachi"]],
      "Số điện thoại": [Icons.phone, account["sodienthoai"]],
      "Email": [Icons.email, account["email"]],
      "Quyền hạn": [
        Icons.security,
        account["quyenhan"] == 'quanly' ? 'Quản lý' : 'Nhân công',
      ],
      "Ngày tạo": [Icons.add_box, _formatDate(account["created_at"])],
      "Cập nhật gần nhất": [Icons.update, _formatDate(account["updated_at"])],
    };

    return entries.entries.map((e) {
      // return ListTile(
      //   leading: Icon(
      //     e.value[0] as IconData,
      //     color: ColorConfig.primary,
      //   ),
      //   title: Text(
      //     "${e.key}:",
      //     style: TextStyle(
      //       fontWeight: FontWeight.bold,
      //       color: Theme.of(context).colorScheme.onSurface,
      //     ),
      //   ),
      //   subtitle: Text(
      //     e.value[1] ?? '',
      //     style: TextStyle(
      //       color: Theme.of(context).colorScheme.onSurfaceVariant,
      //     ),
      //   ),
      // );
      return ListTile(
        leading: Icon(
          e.value[0] as IconData,
          color: ColorConfig.primary,
        ),
        title: Text(
          "${e.key}:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: e.key == "Số điện thoại"
            ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                e.value[1] ?? '',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              tooltip: 'Copy số điện thoại',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: e.value[1] ?? ''));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đã copy số điện thoại")),
                );
              },
            ),
          ],
        )
            : Text(
          e.value[1] ?? '',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );

    }).toList();
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final parsed = DateTime.parse(raw);
      return "${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}";
    } catch (_) {
      return raw;
    }
  }

  String _checkAvatarLink(String avatar) {
    if (avatar.isEmpty || !avatar.startsWith('http')) {
      return "https://i.pinimg.com/736x/35/51/aa/3551aa1febb5d532e2e1909f00c23074.jpg";
    }
    return avatar;
  }

  void _confirmDelete(Map<String, dynamic> account) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text("Xác nhận xóa"),
            content: Text(
              "Bạn có chắc chắn muốn xóa tài khoản '${account["hoten"]}' không?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Hủy"),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  setState(() => _isLoading = true);
                  try {
                    final response = await _accountService.deleteAccountService(
                      account["id"],
                      {"_method": "DELETE"},
                    );
                    if (response["status"] == true || response["code"] == 200) {
                      setState(() {
                        accounts.removeWhere(
                          (acc) => acc["id"] == account["id"],
                        );
                        _filterAccounts();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Đã xóa tài khoản thành công."),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Xóa thất bại: ${response["message"] ?? "Lỗi không xác định"}",
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Lỗi khi xóa tài khoản: $e")),
                    );
                  } finally {
                    setState(() => _isLoading = false);
                  }
                },
                child: const Text("Xóa"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
              ),
            ],
          ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Lọc theo quyền hạn',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Tất cả'),
                      selected: _selectedRole == 'all',
                      onSelected: (selected) {
                        setState(() {
                          _selectedRole = 'all';
                          _filterAccounts();
                        });
                        Navigator.pop(context);
                      },
                    ),
                    FilterChip(
                      label: const Text('Quản lý'),
                      selected: _selectedRole == 'quanly',
                      onSelected: (selected) {
                        setState(() {
                          _selectedRole = 'quanly';
                          _filterAccounts();
                        });
                        Navigator.pop(context);
                      },
                    ),
                    FilterChip(
                      label: const Text('Nhân công'),
                      selected: _selectedRole == 'nhancong',
                      onSelected: (selected) {
                        setState(() {
                          _selectedRole = 'nhancong';
                          _filterAccounts();
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý tài khoản"),
        elevation: 0,
        backgroundColor: ColorConfig.primary,
        foregroundColor: ColorConfig.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAccounts,
            tooltip: 'Làm mới',
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed:
                () => context.push(
                  '/cssx-account-management/cssx-account-create',
                ),
            tooltip: 'Thêm tài khoản',
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFilterBottomSheet,
            tooltip: 'Lọc tài khoản',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Tìm kiếm theo tên hoặc số điện thoại',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainer,
              ),
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredAccounts.isEmpty
                    ? const Center(child: Text('Không có tài khoản nào'))
                    : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: filteredAccounts.length,
                      itemBuilder: (context, index) {
                        final account = filteredAccounts[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            onTap: () => _showAccountDetails(account),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                _checkAvatarLink(account["avatar"]),
                              ),
                              radius: 30,
                              backgroundColor:
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainer,
                            ),
                            title: Text(
                              account["hoten"],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  account["sodienthoai"],
                                  style: TextStyle(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  account["quyenhan"] == 'quanly'
                                      ? 'Quản lý'
                                      : 'Nhân công',
                                  style: TextStyle(
                                    color:
                                        account["quyenhan"] == 'quanly'
                                            ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                            : Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color:
                                        ColorConfig.primary,
                                  ),
                                  onPressed: () {
                                    context.push(
                                      '/cssx-account-management/cssx-account-edit/${account['id']}',
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  onPressed: () => _confirmDelete(account),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
