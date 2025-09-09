import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:txng/config/color_config.dart';

class PostDetailScreen extends StatelessWidget {
  final String title;
  final String image;
  final String description;

  const PostDetailScreen({
    super.key,
    required this.title,
    required this.image,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    final fullContent = '$description\n\n${description * 3}'; // Fake long content

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết bài viết'),
        foregroundColor: ColorConfig.white,
        centerTitle: true,
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh cover
            Hero(
              tag: image,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: Image.network(
                  image,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Thông tin bài viết
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề và metadata
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.visibility,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        "1.2K lượt xem",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Nội dung bài viết
                  Text(
                    fullContent,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.grey.shade800,
                    ),
                    textAlign: TextAlign.justify,
                  ),

                  const SizedBox(height: 30),

                  // Phần tác giả/chia sẻ
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.green.shade100,
                          child: Icon(Icons.person, color: Colors.green.shade800),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Tác giả: Chuyên gia Nông nghiệp",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                              Text(
                                "Hơn 10 năm kinh nghiệm trong lĩnh vực truy xuất nguồn gốc",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.share, color: Colors.green.shade700),
                          onPressed: () {
                            // Chức năng chia sẻ
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Các bài viết liên quan (placeholder)
                  Text(
                    "Bài viết liên quan",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildRelatedPost(
                            "https://i.pinimg.com/736x/94/2c/e6/942ce69dcf19a38f5df896062f592b58.jpg",
                            "Công nghệ mới trong nông nghiệp"),
                        _buildRelatedPost(
                            "https://images.unsplash.com/photo-1605000797499-95a51c5269ae?w=500&auto=format&fit=crop",
                            "Tiêu chuẩn chất lượng GlobalGAP"),
                        _buildRelatedPost(
                            "https://images.unsplash.com/photo-1542838132-92c53300491e?w=500&auto=format&fit=crop",
                            "Hướng dẫn sử dụng QR truy xuất"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Nút like và bình luận
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'like',
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () {},
              child: Icon(Icons.thumb_up, color: Colors.green.shade700),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              heroTag: 'comment',
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () {},
              child: Icon(Icons.comment, color: Colors.green.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedPost(String imageUrl, String title) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        alignment: Alignment.bottomLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}