import 'package:flutter/material.dart';
import '../services/data_source_service.dart';
import '../models/data_sources.dart';

class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  final DataSourceService _dataService = DataSourceService();
  bool _isLoading = false;
  Map<String, bool> _downloadResults = {};
  List<DataSourceConfig> _dataSources = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await _dataService.initialize();
      setState(() {
        _dataSources = _dataService.getDataSourceConfigs();
      });
    } catch (e) {
      print('Error initializing data service: $e');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing data service: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadAllDataSources() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Show downloading message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Downloading all data sources... This may take a while'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.orange,
          ),
        );
      }

      final results = <String, bool>{};
      
      // Download each data source
      for (final source in _dataSources) {
        final sourceName = source.name.toLowerCase().replaceAll(' ', '_');
        final fileId = source.metadata['file_id'] as String?;
        
        if (fileId != null) {
          final fileName = '${sourceName}.csv';
          final subfolder = source.type;
          
          final success = await _dataService.downloadFileFromDrive(
            fileId: fileId,
            fileName: fileName,
            subfolder: subfolder,
          );
          
          results[sourceName] = success;
        } else {
          results[sourceName] = false;
        }
      }
      
      setState(() {
        _downloadResults = results;
        _isLoading = false;
      });

      // Show success dialog
      _showDownloadResultsDialog();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Download failed: $e');
    }
  }

  Future<void> _downloadDataSource(String sourceName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Find the data source configuration
      final sourceConfig = _dataSources.firstWhere(
        (source) => source.name.toLowerCase().replaceAll(' ', '_') == sourceName,
        orElse: () => _dataSources.first,
      );
      
      // Get file ID from metadata
      final fileId = sourceConfig.metadata['file_id'] as String?;
      
      if (fileId == null) {
        throw Exception('File ID not found for $sourceName');
      }
      
      // Show downloading message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Downloading... Please wait'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
      }
      
      // Download the file
      final fileName = '${sourceName}.csv';
      final subfolder = sourceConfig.type;
      
      final success = await _dataService.downloadFileFromDrive(
        fileId: fileId,
        fileName: fileName,
        subfolder: subfolder,
      );
      
      setState(() {
        _downloadResults[sourceName] = success;
        _isLoading = false;
      });

      if (success) {
        _showSuccessDialog('Downloaded successfully to device!');
      } else {
        _showErrorDialog('Download failed. Please check your internet connection.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Download failed: $e');
    }
  }

  void _showDownloadResultsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _downloadResults.entries.map((entry) {
            return ListTile(
              leading: Icon(
                entry.value ? Icons.check_circle : Icons.error,
                color: entry.value ? Colors.green : Colors.red,
              ),
              title: Text(entry.key.replaceAll('_', ' ').toUpperCase()),
              subtitle: Text(entry.value ? 'Downloaded successfully' : 'Download failed'),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Sources Management'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Data Sources Setup',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Manage and download data sources for Chesapeake Bay SAR analysis',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _downloadAllDataSources,
                                  icon: const Icon(Icons.download),
                                  label: const Text('Download All'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    // TODO: Implement Earth Engine setup guide
                                    _showEarthEngineSetupDialog();
                                  },
                                  icon: const Icon(Icons.cloud),
                                  label: const Text('Setup Guide'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Data Sources List
                  const Text(
                    'Available Data Sources',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._dataSources.map((source) => _buildDataSourceCard(source)),
                  const SizedBox(height: 16),

                  // Earth Engine Script Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Earth Engine Script',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Use the provided Earth Engine script to collect 10 years of Sentinel-1 SAR data for Chesapeake Bay region.',
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    // TODO: Open Earth Engine script
                                    _showEarthEngineScriptDialog();
                                  },
                                  icon: const Icon(Icons.code),
                                  label: const Text('View'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    // TODO: Copy script to clipboard
                                    _copyScriptToClipboard();
                                  },
                                  icon: const Icon(Icons.copy),
                                  label: const Text('Copy'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDataSourceCard(DataSourceConfig source) {
    final isDownloaded = _downloadResults[source.name.toLowerCase().replaceAll(' ', '_')] ?? false;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDownloaded ? Colors.green : Colors.blue,
          child: Icon(
            isDownloaded ? Icons.check : Icons.download,
            color: Colors.white,
          ),
        ),
        title: Text(source.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(source.description),
            const SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Chip(
                  label: Text(source.format),
                  backgroundColor: Colors.blue.withOpacity(0.2),
                ),
                const SizedBox(height: 4),
                Chip(
                  label: Text(source.source),
                  backgroundColor: Colors.green.withOpacity(0.2),
                ),
              ],
            ),
          ],
        ),
        trailing: isDownloaded
            ? const Icon(Icons.check_circle, color: Colors.green)
            : IconButton(
                onPressed: () => _downloadDataSource(
                  source.name.toLowerCase().replaceAll(' ', '_'),
                ),
                icon: const Icon(Icons.download),
              ),
      ),
    );
  }

  void _showEarthEngineSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Google Earth Engine Setup'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('To set up Google Earth Engine:'),
            SizedBox(height: 8),
            Text('1. Visit https://earthengine.google.com/'),
            Text('2. Sign up with your Google account'),
            Text('3. Request access to Earth Engine'),
            Text('4. Wait for approval (usually 1-2 days)'),
            Text('5. Access the Code Editor'),
            SizedBox(height: 8),
            Text('Once approved, you can run the SAR data collection script.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEarthEngineScriptDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Earth Engine Script'),
        content: const SingleChildScrollView(
          child: Text(
            'The Earth Engine script collects 10 years of Sentinel-1 SAR data for Chesapeake Bay region. It creates annual and monthly composites, processes SAR indices, and exports data to Google Drive.\n\n'
            'Key features:\n'
            '• 10-year data collection (2014-2024)\n'
            '• Annual and monthly composites\n'
            '• Summer composites for oil spill analysis\n'
            '• SAR preprocessing and indices\n'
            '• Export to Google Drive\n\n'
            'The script is located in: earth_engine_scripts/sentinel1_chesapeake_bay.js',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _copyScriptToClipboard() {
    // TODO: Implement clipboard functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Script copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
