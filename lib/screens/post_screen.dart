import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'post_detail_screen.dart';

class ListPostScreen extends StatefulWidget {
  const ListPostScreen({super.key});

  @override
  State<ListPostScreen> createState() => _ListPostScreenState();
}

class _ListPostScreenState extends State<ListPostScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showBottomBar = true;
  String _searchText = "";

  final List<Map<String, String>> _posts = [
    {
      "title": "Công nghệ Blockchain trong truy xuất nguồn gốc nông sản",
      "image": "https://images.unsplash.com/photo-1639762681057-408e52192e55?w=500&auto=format&fit=crop",
      "description": "Ứng dụng công nghệ blockchain giúp minh bạch hóa chuỗi cung ứng nông sản từ trang trại đến bàn ăn...",
      "view": "1.4k"
    },
    {
      "title": "Hướng dẫn truy xuất nguồn gốc rau hữu cơ bằng QR code",
      "image": "https://images.unsplash.com/photo-1542838132-92c53300491e?w=500&auto=format&fit=crop",
      "description": "Cách sử dụng QR code để kiểm tra nguồn gốc, quy trình sản xuất và chứng nhận hữu cơ của rau củ...",
      "view": "12k"
    },
    {
      "title": "Lợi ích của truy xuất nguồn gốc với người tiêu dùng",
      "image": "https://images.unsplash.com/photo-1606787366850-de6330128bfc?w=500&auto=format&fit=crop",
      "description": "Người tiêu dùng được bảo vệ thế nào khi biết rõ nguồn gốc, xuất xứ của thực phẩm mình sử dụng...",
      "view": "2.1k"
    },
    {
      "title": "Giải pháp IoT trong nông nghiệp thông minh",
      "image": "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=500&auto=format&fit=crop",
      "description": "Cảm biến IoT giám sát nhiệt độ, độ ẩm giúp tối ưu hóa sản xuất và truy xuất dữ liệu nông nghiệp...",
      "view": "1.3k"
    },
    {
      "title": "Tiêu chuẩn GlobalGAP trong sản xuất nông nghiệp",
      "image": "https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=500&auto=format&fit=crop",
      "description": "Tìm hiểu về bộ tiêu chuẩn toàn cầu đảm bảo an toàn thực phẩm và truy xuất nguồn gốc rõ ràng...",
      "view": "1.7k"
    },
    {
      "title": "Công nghệ RFID ứng dụng trong quản lý nông sản",
      "image": "https://images.unsplash.com/photo-1605000797499-95a51c5269ae?w=500&auto=format&fit=crop",
      "description": "Sử dụng thẻ RFID để theo dõi từng lô hàng nông sản qua các khâu trong chuỗi cung ứng...",
      "view": "1k"

    },
    {
      "title": "Xu hướng nông nghiệp xanh và minh bạch thông tin",
      "image": "https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=500&auto=format&fit=crop",
      "description": "Nông nghiệp bền vững kết hợp công nghệ truy xuất nguồn gốc - xu thế tất yếu của tương lai...",
      "view": "2.2k"
    },
    {
      "title": "Phần mềm quản lý truy xuất nguồn gốc cho hợp tác xã",
      "image": "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=500&auto=format&fit=crop",
      "description": "Giải pháp công nghệ giúp các hợp tác xã nông nghiệp quản lý và truy xuất thông tin sản phẩm dễ dàng...",
      "view": "3,6k"
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_showBottomBar) {
        setState(() => _showBottomBar = false);
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_showBottomBar) {
        setState(() => _showBottomBar = true);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredPosts = _posts
        .where((post) =>
        post["title"]!.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kiến Thức Nông Nghiệp", style: TextStyle(color: Colors.white),),
        centerTitle: true,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade700, Colors.lightGreen.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Tìm kiếm bài viết về nông nghiệp...",
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),
          ),

          // Danh sách bài viết
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: filteredPosts.length,
              itemBuilder: (context, index) {
                final post = filteredPosts[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PostDetailScreen(
                            title: post["title"]!,
                            image: post["image"]!,
                            description: post["description"]!,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                            child: Image.network(
                              post["image"]!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post["title"]!,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    post["description"]!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          size: 14, color: Colors.grey.shade500),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade500),
                                      ),
                                      const Spacer(),
                                      Icon(Icons.visibility,
                                          size: 14, color: Colors.grey.shade500),
                                      const SizedBox(width: 4),
                                      Text("${post['view']}",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade500)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Thanh điều hướng dưới cùng
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: _showBottomBar ? 70 : 0,
        curve: Curves.easeInOut,
        child: _showBottomBar
            ? Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                    ),
                    onPressed: () {
                      context.push('/option-login');
                    },
                    icon: const Icon(Icons.login),
                    label: const Text("Đăng nhập")),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      side: BorderSide(color: Colors.green.shade700),
                    ),
                    onPressed: () {
                      context.push('/register');
                    },
                    icon: const Icon(Icons.app_registration),
                    label: const Text("Đăng ký")),
              ),
            ],
          ),
        )
            : const SizedBox.shrink(),
      ),
    );
  }
}