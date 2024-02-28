import 'dart:io';
import 'package:ssh2/ssh2.dart';
import 'package:path_provider/path_provider.dart';
import '../entities/look_at_entity.dart';

class LGService {
  final SSHClient _client;
  LGService(SSHClient client) : _client = client;
  static LGService? shared;
  final String _url = 'http://lg1:81';

  int screenAmount = 5;

  Future<String?> getScreenAmount() async {
    return _client
        .execute("grep -oP '(?<=DHCP_LG_FRAMES_MAX=).*' personavars.txt");
  }

  int get firstScreen {
    if (screenAmount == 1) {
      return 1;
    }
    return (screenAmount / 2).floor() + 2;
  }

  int get lastScreen {
    if (screenAmount == 1) {
      return 1;
    }
    return (screenAmount / 2).floor() + 1;
  }

  Future<void> setRefresh() async {
    final pw = _client.passwordOrKey;

    const search = '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href>';
    const replace =
        '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href><refreshMode>onInterval<\\/refreshMode><refreshInterval>2<\\/refreshInterval>';
    final command =
        'echo $pw | sudo -S sed -i "s/$search/$replace/" ~/earth/kml/slave/myplaces.kml';

    final clear =
        'echo $pw | sudo -S sed -i "s/$replace/$search/" ~/earth/kml/slave/myplaces.kml';

    for (var i = 2; i <= screenAmount; i++) {
      final clearCmd = clear.replaceAll('{{slave}}', i.toString());
      final cmd = command.replaceAll('{{slave}}', i.toString());
      String query = 'sshpass -p $pw ssh -t lg$i \'{{cmd}}\'';

      try {
        await _client.execute(query.replaceAll('{{cmd}}', clearCmd));
        await _client.execute(query.replaceAll('{{cmd}}', cmd));
      } catch (e) {
        // ignore: avoid_print
        print(e);
      }
    }

    await reboot();
  }

  Future<void> resetRefresh() async {
    final pw = _client.passwordOrKey;

    const search =
        '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href><refreshMode>onInterval<\\/refreshMode><refreshInterval>2<\\/refreshInterval>';
    const replace = '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href>';

    final clear =
        'echo $pw | sudo -S sed -i "s/$search/$replace/" ~/earth/kml/slave/myplaces.kml';

    for (var i = 2; i <= screenAmount; i++) {
      final cmd = clear.replaceAll('{{slave}}', i.toString());
      String query = 'sshpass -p $pw ssh -t lg$i \'$cmd\'';

      try {
        await _client.execute(query);
      } catch (e) {
        // ignore: avoid_print
        print(e);
      }
    }

    await reboot();
  }

  Future<void> relaunch() async {
    final pw = _client.passwordOrKey;
    final user = _client.username;

    for (var i = screenAmount; i >= 1; i--) {
      try {
        final relaunchCommand = """RELAUNCH_CMD="\\
if [ -f /etc/init/lxdm.conf ]; then
  export SERVICE=lxdm
elif [ -f /etc/init/lightdm.conf ]; then
  export SERVICE=lightdm
else
  exit 1
fi
if  [[ \\\$(service \\\$SERVICE status) =~ 'stop' ]]; then
  echo $pw | sudo -S service \\\${SERVICE} start
else
  echo $pw | sudo -S service \\\${SERVICE} restart
fi
" && sshpass -p $pw ssh -x -t lg@lg$i "\$RELAUNCH_CMD\"""";
        await _client
            .execute('"/home/$user/bin/lg-relaunch" > /home/$user/log.txt');
        await _client.execute(relaunchCommand);
      } catch (e) {
        // ignore: avoid_print
        print(e);
      }
    }
  }

  Future<void> poweroff() async {
    final pw = _client.passwordOrKey;

    for (var i = screenAmount; i >= 1; i--) {
      try {
        await _client.execute(
            'sshpass -p $pw ssh -t lg$i "echo $pw | sudo -S poweroff"');
      } catch (e) {
        // ignore: avoid_print
        print(e);
      }
    }
  }

  Future<void> reboot() async {
    final pw = _client.passwordOrKey;

    for (var i = screenAmount; i >= 1; i--) {
      try {
        await _client
            .execute('sshpass -p $pw ssh -t lg$i "echo $pw | sudo -S reboot"');
      } catch (e) {
        // ignore: avoid_print
        print(e);
      }
    }
  }



  Future<void> sendKMLToSlave(int screen, String content) async {
    try {
      await _client
          .execute("echo '$content' > /var/www/html/kml/slave_$screen.kml");
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  Future<void> sendKml(String kml) async {
    const fileName = 'prova.kml';

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    file.writeAsStringSync(kml);

    await _client.connectSFTP();
    await _client.sftpUpload(
        path: file.path,
        toPath: '/var/www/html',
        callback: (progress) {
          print('Sent $progress');
        });
    await _client.execute('echo "$_url/${fileName}" > /var/www/html/kmls.txt');
  }


  Future<void> sendTour(double latitude, double longitude, double zoom,
      double tilt, double bearing) async {
    await query(
        'flytoview=${LookAtEntity.lookAtLinear(latitude, longitude, zoom, tilt, bearing)}');
  }

  Future<void> query(String content) async {
    await _client.execute('echo "$content" > /tmp/query.txt');
  }

  Future<Object?> sendOrbit(String tourKml, String tourName) async {
    final fileName = '$tourName.kml';

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    file.writeAsStringSync(tourKml);

    await _client.connectSFTP();
    await _client.sftpUpload(
        path: file.path,
        toPath: '/var/www/html',
        callback: (progress) {
          print('Sent $progress');
        });
    _client.execute(
        "echo '\nhttp://lg1:81/${fileName}' >> /var/www/html/kmls.txt");

    try {
      return await _client.execute('echo "playtour=Orbit" > /tmp/query.txt');
    } catch (e) {
      print('Could not connect to host LG');
      return Future.error(e);
    }
  }
}