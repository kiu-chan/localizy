import 'package:flutter/material.dart';

class RequestListPage extends StatefulWidget {
  const RequestListPage({super.key});

  @override
  State<RequestListPage> createState() => _RequestListPageState();
}

class _RequestListPageState extends State<RequestListPage> {
  String _selectedFilter = 'Tất cả';

  final List<Map<String, dynamic>> _requests = [
    {
      'id': '001',
      'title': 'Thêm địa điểm mới - Cà phê Highlands',
      'location': 'Hà Nội',
      'date': '04/01/2026',
      'status': 'Chờ xử lý',
      'type': 'Thêm mới',
    },
    {
      'id': '002',
      'title': 'Cập nhật thông tin - Nhà hàng ABC',
      'location': 'TP. Hồ Chí Minh',
      'date': '03/01/2026',
      'status': 'Đang xử lý',
      'type': 'Cập nhật',
    },
    {
      'id': '003',
      'title': 'Xóa địa điểm - Quán ăn XYZ',
      'location':  'Đà Nẵng',
      'date': '03/01/2026',
      'status': 'Đã hoàn thành',
      'type': 'Xóa',
    },
    {
      'id': '004',
      'title': 'Thêm địa điểm mới - Siêu thị Mini',
      'location': 'Hải Phòng',
      'date': '02/01/2026',
      'status': 'Từ chối',
      'type': 'Thêm mới',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Danh sách yêu cầu',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis. horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('Tất cả'),
                _buildFilterChip('Chờ xử lý'),
                _buildFilterChip('Đang xử lý'),
                _buildFilterChip('Đã hoàn thành'),
                _buildFilterChip('Từ chối'),
              ],
            ),
          ),

          // Request list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                final request = _requests[index];
                return _buildRequestCard(request);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = label;
          });
        },
        backgroundColor: Colors.grey.shade200,
        selectedColor: Colors.green.shade100,
        labelStyle: TextStyle(
          color: isSelected ? Colors.green. shade700 : Colors.grey. shade700,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        checkmarkColor: Colors.green.shade700,
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    Color statusColor;
    switch (request['status']) {
      case 'Chờ xử lý':
        statusColor = Colors.orange;
        break;
      case 'Đang xử lý':
        statusColor = Colors.blue;
        break;
      case 'Đã hoàn thành': 
        statusColor = Colors.green;
        break;
      case 'Từ chối': 
        statusColor = Colors.red;
        break;
      default: 
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow:  [
          BoxShadow(
            color: Colors.black. withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _showRequestDetail(request);
          },
          child:  Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius:  BorderRadius.circular(4),
                      ),
                      child: Text(
                        request['type'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '#${request['id']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors. grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  request['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors. grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      request['location'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors. grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.calendar_today,
                      size:  16,
                      color:  Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      request['date'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height:  12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius:  BorderRadius.circular(20),
                      ),
                      child:  Text(
                        request['status'],
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey.shade400,
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lọc yêu cầu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Theo trạng thái'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Theo loại yêu cầu'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Theo địa điểm'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showRequestDetail(Map<String, dynamic> request) {
    showModalBottomSheet(
      context:  context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child:  Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  request['title'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height:  16),
                _buildDetailRow('Mã yêu cầu', '#${request['id']}'),
                _buildDetailRow('Loại yêu cầu', request['type']),
                _buildDetailRow('Địa điểm', request['location']),
                _buildDetailRow('Ngày gửi', request['date']),
                _buildDetailRow('Trạng thái', request['status']),
                const SizedBox(height: 24),
                const Text(
                  'Mô tả chi tiết',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Đây là mô tả chi tiết về yêu cầu. Người dùng muốn thêm/cập nhật/xóa địa điểm với các thông tin cụ thể.. .',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors. grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                if (request['status'] == 'Chờ xử lý')
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton. icon(
                          onPressed:  () {
                            Navigator.pop(context);
                            _showApproveDialog();
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Duyệt'),
                          style: ElevatedButton. styleFrom(
                            backgroundColor:  Colors.green.shade700,
                            foregroundColor: Colors. white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showRejectDialog();
                          },
                          icon: const Icon(Icons.close),
                          label: const Text('Từ chối'),
                          style: OutlinedButton. styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets. symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style:  const TextStyle(
                fontSize:  14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showApproveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận duyệt'),
        content: const Text('Bạn có chắc chắn muốn duyệt yêu cầu này? '),
        actions: [
          TextButton(
            onPressed:  () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã duyệt yêu cầu thành công'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận từ chối'),
        content: const Text('Bạn có chắc chắn muốn từ chối yêu cầu này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed:  () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:  Text('Đã từ chối yêu cầu'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );
  }
}