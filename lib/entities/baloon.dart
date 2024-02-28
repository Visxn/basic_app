

class KMLBalloonEntity {
  String name ='Roger';
  String city ='Lleida';
  String screenOverlay;

  KMLBalloonEntity({
    required this.name,
    required this.city,
    this.screenOverlay = '',
  });


  String get body => '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document>
	<name>$name.kml</name>
	<Style id="purple_paddle">
		<BalloonStyle>
		 <IconStyle>
    <scale>1.3</scale>
   
  </IconStyle>
			<text>\$[description]</text>
      <bgColor>ff1e1e1e</bgColor>
		</BalloonStyle>
	</Style>
	<Placemark id="0A7ACC68BF23CB81B354">
		<Snippet maxLines="0"></Snippet>
		<description><![CDATA[<!-- BalloonStyle background color:
ffffffff
 -->
<!-- Icon URL:
http://maps.google.com/mapfiles/kml/paddle/purple-blank.png
 -->

<div style="margin: 20px;">
    <tr>
      <td align="left"><h1><font color='#00CC99'>City name:</font></h1></td>
      <td align="center"><h1><font color='#00CC99'>$city</font></h1></td>
    </tr>
      <tr>
      <td align="left"><h1><font color='#00CC99'>Developer name:</font></h1></td>
      <td align="center"><h1><font color='#00CC99'>$name</font></h1></td>
    </tr>

</div>

</Document>
</kml>
  ''';
}