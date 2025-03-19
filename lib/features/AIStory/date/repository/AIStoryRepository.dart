import 'package:hikayati_app/dataProviders/local_data_provider.dart';
import 'package:hikayati_app/dataProviders/network/Network_info.dart';
import 'package:hikayati_app/dataProviders/network/data_source_url.dart';
import 'package:hikayati_app/dataProviders/remote_data_provider.dart';
import 'package:hikayati_app/dataProviders/repository.dart';
import 'package:dartz/dartz.dart';
import 'package:hikayati_app/features/AIStory/date/model/AIStoryModel.dart';

import '../../../../dataProviders/error/failures.dart';

class AIStoryRepository extends Repository {
  final RemoteDataProvider remoteDataProvider; // Get the data from the internet
  final LocalDataProvider localDataProvider; // Get the data from the local cache
  final NetworkInfo networkInfo; // Check if the device is connected to internet

  AIStoryRepository({
    required this.remoteDataProvider,
    required this.localDataProvider,
    required this.networkInfo,
  });

  Future<Either<Failure, dynamic>> getAIStory(String storyId) async {
    return await sendRequest(
      checkConnection: networkInfo.isConnected,
      remoteFunction: () async {
        final AIStoryModel remoteData = await remoteDataProvider.getData(
          url: "${DataSourceURL.getAIStorySlides}$storyId",
          retrievedDataType: AIStoryModel.init(),
          returnType: AIStoryModel,
        );
        return remoteData;
      },
    );
  }
} 