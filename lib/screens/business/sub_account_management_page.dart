import 'package:flutter/material.dart';

class SubAccountManagementPage extends StatefulWidget {
  const SubAccountManagementPage({super.key});

  @override
  State<SubAccountManagementPage> createState() => _SubAccountManagementPageState();
}

class _SubAccountManagementPageState extends State<SubAccountManagementPage> {
  final List<Map<String, dynamic>> _subAccounts = [
    {
      'id': '001',
      'name': 'John Manager',
      'email': 'john. manager@business.com',
      'role': 'Manager',
      'status': 'Active',
      'locations': 5,
      'createdDate': '01/01/2026',
    },
    {
      'id': '002',
      'name': 'Sarah Editor',
      'email': 'sarah.editor@business.com',
      'role': 'Editor',
      'status': 'Active',
      'locations': 3,
      'createdDate': '15/01/2026',
    },
    {
      'id': '003',
      'name': 'Mike Viewer',
      'email': 'mike.viewer@business.com',
      'role': 'Viewer',
      'status': 'Inactive',
      'locations': 0,
      'createdDate':  '20/12/2025',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Sub Account Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton. extended(
        onPressed: () {
          _showAddAccountDialog();
        },
        backgroundColor: Colors.blue.shade700,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Account'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _subAccounts.length,
        itemBuilder: (context, index) {
          final account = _subAccounts[index];
          return _buildAccountCard(account);
        },
      ),
    );
  }

  Widget _buildAccountCard(Map<String, dynamic> account) {
    Color statusColor = account['status'] == 'Active' ? Colors.green : Colors.grey;
    Color roleColor;
    
    switch (account['role']) {
      case 'Manager':
        roleColor = Colors. purple;
        break;
      case 'Editor':
        roleColor = Colors.blue;
        break;
      case 'Viewer':
        roleColor = Colors.orange;
        break;
      default:
        roleColor = Colors. grey;
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
            _showAccountDetail(account);
          },
          child:  Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        account['name']. substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            account['email'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors. grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        account['status'],
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.badge,
                            size: 14,
                            color: roleColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            account['role'],
                            style: TextStyle(
                              fontSize: 12,
                              color: roleColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.location_on,
                      size:  16,
                      color: Colors. grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${account['locations']} locations',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors. grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.calendar_today,
                      size:  14,
                      color: Colors. grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      account['createdDate'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
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

  void _showAddAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Sub Account'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize. min,
            children: [
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons. person),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText:  'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons. badge),
                ),
                items: const [
                  DropdownMenuItem(value: 'Manager', child: Text('Manager')),
                  DropdownMenuItem(value:  'Editor', child: Text('Editor')),
                  DropdownMenuItem(value: 'Viewer', child: Text('Viewer')),
                ],
                onChanged: (value) {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sub account created successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAccountDetail(Map<String, dynamic> account) {
    showModalBottomSheet(
      context:  context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color:  Colors.grey.shade300,
                  borderRadius: BorderRadius. circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors. blue.shade100,
                  child: Text(
                    account['name'].substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account['name'],
                        style: const TextStyle(
                          fontSize:  20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        account['email'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Account ID', '#${account['id']}'),
            _buildDetailRow('Role', account['role']),
            _buildDetailRow('Status', account['status']),
            _buildDetailRow('Managed Locations', '${account['locations']}'),
            _buildDetailRow('Created Date', account['createdDate']),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child:  OutlinedButton. icon(
                    onPressed:  () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade700,
                      side: BorderSide(color: Colors.blue.shade700),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width:  12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showDeleteConfirmDialog(account);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
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
            width: 140,
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

  void _showDeleteConfirmDialog(Map<String, dynamic> account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text('Are you sure you want to delete ${account['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}