import java.util.stream.Collectors;
import processing.svg.*;

int N_RACOONS = 4;

void setup() {
  size(720,720);
  
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
  
  // Transforms base racoon to base (and final) shape
  AffineTransformation baseTransformation = new AffineTransformation();
  Point centroid = baseRacoon.getCentroid();
  baseTransformation.translate(-centroid.getX(),-centroid.getY());
  double diameter = 2*(new MinimumBoundingCircle(baseRacoon)).getRadius();
  baseTransformation.scale(0.95*width/(diameter*N_RACOONS),0.95*height/(diameter*N_RACOONS));
  baseTransformation.rotate(PI);
  
  // Progressively add new racoons
  ArrayList<Polygon> racoons = new ArrayList<Polygon>();
  for(int i=0; i<N_RACOONS; i++) {
    for(int j=0; j<N_RACOONS; j++) {
      AffineTransformation t = new AffineTransformation(baseTransformation);
      t.translate((width/N_RACOONS) * (i+0.5), (height/N_RACOONS) * (j+0.5));
      Polygon racoon = (Polygon) t.transform(baseRacoon);
      racoons.add(racoon);
    }
  }
  
  beginRecord(SVG, "out/final.svg");
  
  background(255);
  noFill();
  stroke(0);
  for(Polygon racoon : racoons) {
    beginShape();
    for(Coordinate coord : racoon.getExteriorRing().getCoordinates()) {
      vertex((float) coord.x, (float) coord.y);
    }
    endShape();
    for(int i=0; i<racoon.getNumInteriorRing(); i++) {
      beginShape();
      for(Coordinate coord : racoon.getInteriorRingN(i).getCoordinates()){
        vertex((float) coord.x, (float) coord.y);
      }
      endShape();
    }
  }
  endRecord();
  noLoop();
}
