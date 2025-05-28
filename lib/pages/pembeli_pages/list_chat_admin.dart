import 'package:flutter/material.dart';
import 'package:frontend/models/pembeli_model.dart';
import 'package:frontend/pages/chat_pages/chat.dart';
import 'package:toastification/toastification.dart';

class AdminListPage extends StatefulWidget {
  @override
  _AdminListPageState createState() => _AdminListPageState();
}

class _AdminListPageState extends State<AdminListPage> {
  List<GetDataAdmin> adminList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAdminList();
  }

  Future<void> loadAdminList() async {
    try {
      final admins = await GetDataAdmin.getDataAdmin();
      setState(() {
        adminList = admins;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        title: Text('Error'),
        description: Text('Gagal memuat data admin: $e'),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: highModeShadow,
        closeButtonShowType: CloseButtonShowType.onHover,
        closeOnClick: false,
        pauseOnHover: true,
        dragToClose: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Customer Service',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              )
              : adminList.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.support_agent,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Tidak ada customer service tersedia',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: loadAdminList,
                color: Colors.black,
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: adminList.length,
                  itemBuilder: (context, index) {
                    final admin = adminList[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                        border: Border.all(color: Colors.grey[200]!, width: 1),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(
                            Icons.support_agent,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          'Customer Service ${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(
                              'Siap membantu Anda',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green[200]!,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Online',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey[400],
                          size: 16,
                        ),
                        onTap: () {
                          print('Navigating to chat with admin: ${admin.id}');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ChatPage(
                                    recipientId: admin.id,
                                    recipientName:
                                        'Customer Service ${index + 1}',
                                    isAdminChat: false, // pembeli ke admin
                                  ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
