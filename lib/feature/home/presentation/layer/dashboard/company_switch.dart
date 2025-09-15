import 'package:cbook_dt/feature/dashboard_report/model/company_model.dart';
import 'package:cbook_dt/feature/dashboard_report/provider/dashbord_report_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CompanySwitchModal extends StatelessWidget {
  final Function(CompanyModel) onCompanySelected;

  const CompanySwitchModal({
    Key? key,
    required this.onCompanySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Switch Account',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Company list from API
          Expanded(
            child: Consumer<DashboardReportProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingCompanyList ||
                    provider.isSwitchingCompany) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 10),
                        Text(
                          provider.isSwitchingCompany
                              ? 'Switching company...'
                              : 'Loading companies...',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.errorCompanyList != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${provider.errorCompanyList}',
                          style: const TextStyle(color: Colors.red),
                        ),
                        ElevatedButton(
                          onPressed: () => provider.fetchCompanyList(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.companyList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No companies found'),
                        ElevatedButton(
                          onPressed: () => provider.fetchCompanyList(),
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: provider.companyList.length,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemBuilder: (context, index) {
                    final company = provider.companyList[index];
                    final isEnabled = company.status == 1;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      child: ListTile(
                        dense: true,
                        visualDensity: const VisualDensity(vertical: -3),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isEnabled
                                ? Colors.grey[200]!
                                : Colors.grey[400]!,
                            width: 1,
                          ),
                        ),
                        enabled: isEnabled,
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              isEnabled ? Colors.blue : Colors.grey,
                          child: (company.logo != null &&
                                  company.logo!.isNotEmpty)
                              ? ClipOval(
                                  child: Image.network(
                                    'https://commercebook.site/${company.logo}',
                                    fit: BoxFit.cover,
                                    width: 40,
                                    height: 40,
                                    errorBuilder: (context, error, stackTrace) {
                                      // fallback if image fails to load
                                      return Text(
                                        company.companyName.isNotEmpty
                                            ? company.companyName[0]
                                                .toUpperCase()
                                            : "?",
                                        style: TextStyle(
                                          color: isEnabled
                                              ? Colors.white
                                              : Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Text(
                                  company.companyName.isNotEmpty
                                      ? company.companyName[0].toUpperCase()
                                      : "?",
                                  style: TextStyle(
                                    color: isEnabled
                                        ? Colors.white
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        title: Text(
                          company.companyName,
                          style: TextStyle(
                            color: isEnabled ? Colors.black : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              company.role ?? 'N/A', //id: company.id
                              style: TextStyle(
                                color: isEnabled ? Colors.black54 : Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isEnabled ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                isEnabled ? 'Open' : 'Pending',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color:
                              isEnabled ? Colors.grey[400] : Colors.grey[300],
                        ),
                        onTap: isEnabled
                            ? () {
                                // Close modal first
                                Navigator.pop(context);
                                // Then handle company switch in parent context
                                onCompanySelected(company);
                              }
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Add account button
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: SizedBox(
          //     width: double.infinity,
          //     child: OutlinedButton.icon(
          //       onPressed: () {
          //         Navigator.pop(context);
          //         // Handle add new account
          //       },
          //       icon: const Icon(Icons.add),
          //       label: const Text('Add Another Account'),
          //       style: OutlinedButton.styleFrom(
          //         padding: const EdgeInsets.symmetric(vertical: 12),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
