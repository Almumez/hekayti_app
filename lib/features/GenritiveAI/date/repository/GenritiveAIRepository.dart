import 'package:hikayati_app/dataProviders/local_data_provider.dart';
import 'package:hikayati_app/dataProviders/network/Network_info.dart';
import 'package:hikayati_app/dataProviders/network/data_source_url.dart';
import 'package:hikayati_app/dataProviders/remote_data_provider.dart';
import 'package:hikayati_app/dataProviders/repository.dart';
import 'package:dartz/dartz.dart';
import 'package:hikayati_app/features/GenritiveAI/date/model/GenritiveAIMode.dart';
import 'package:hikayati_app/features/Story/date/model/accuracyModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/util/Common.dart';
import '../../../../core/util/Encrypt.dart';
import '../../../../dataProviders/error/failures.dart';
import '../../../../main.dart';


class GenritiveAIRepository extends Repository {
  final RemoteDataProvider remoteDataProvider; //get the data from the internet
  final LocalDataProvider localDataProvider; //get the data from the local cache
  final NetworkInfo networkInfo; //check if the device is connected to internet

  GenritiveAIRepository({
    required this.remoteDataProvider,
    required this.localDataProvider,
    required this.networkInfo,
  });

  Future<Either<Failure, dynamic>> GenritiveAI() async
  {


    return await sendRequest(
        checkConnection: networkInfo.isConnected,
        remoteFunction: () async {
          List<GenritiveAIMode> remoteData = await remoteDataProvider.getData(
              url: DataSourceURL.getAIStory,
              retrievedDataType: GenritiveAIMode.init(),
              returnType: List,
              );




          return remoteData;
        });
  }



  Future<Either<Failure, dynamic>> GenritiveAIStory({ required String ? hero_name,required String ? painting_style,required String ? story_topic }) async
  {
    return await sendRequest(
        checkConnection: networkInfo.isConnected,
        remoteFunction: () async {
          GenritiveAIMode remoteData = await remoteDataProvider.sendJsonData(
            url: DataSourceURL.generateAIStory,
            retrievedDataType: GenritiveAIMode.init(),
            returnType: GenritiveAIMode.init(),
            body: {
              "hero_name": hero_name,
              "painting_style": painting_style,
              "story_topic":  story_topic
            }
          );
          return remoteData;
        });
  }

}
