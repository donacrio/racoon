import java.util.stream.Collectors;
import processing.svg.*;

void setup() {
  size(480, 480);
  
  GeometryFactory GF = new GeometryFactory();
  
  // Load Racoon geometry
  Geometry baseRacoon = GF.createPolygon();
  String[] lines = loadStrings("data/racoon.txt");
  WKTReader reader = new WKTReader(GF);
  try {
    baseRacoon = reader.read(lines[0]);
  } catch(ParseException e) {
    println(e);
  }
  // Transforms base racoon
  AffineTransformation baseTransformation = new AffineTransformation();
  Point centroid = baseRacoon.getCentroid();
  baseTransformation.translate(-centroid.getX(),-centroid.getY());
  double diameter = 2*(new MinimumBoundingCircle(baseRacoon)).getRadius();
  baseTransformation.scale(width/diameter,height/diameter);
  baseTransformation.rotate(PI);
  baseRacoon = baseTransformation.transform(baseRacoon);
  
  beginRecord(SVG, "out/final.svg");
  background(255);
  noFill();
  stroke(0);
  translate(width/2, height/2);
  for(Coordinate coord : baseRacoon.getCoordinates()) {
    point((float) coord.x, (float) coord.y);
  }
  endRecord();
  noLoop();
}
