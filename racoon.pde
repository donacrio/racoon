import java.util.stream.Collectors;
import processing.svg.*;

int N_RACOONS_ROW = 4;
int N_RACOONS_COL = 7;

GeometryFactory GF;

void setup() {
  //size(9000, 12600);
  size(618, 1080);
  
  GF = new GeometryFactory();
  
  // Load Racoon geometry
  Geometry baseRacoon = GF.createPolygon();
  WKTReader reader = new WKTReader(GF);
  try {
    baseRacoon = reader.read(loadStrings("data/racoon.txt")[0]);
  } catch(ParseException e) {
    println(e);
  }
  
  // Transforms base racoon to base shape
  AffineTransformation baseTransformation = new AffineTransformation();
  Point centroid = baseRacoon.getCentroid();
  baseTransformation.translate(-centroid.getX(),-centroid.getY());
  double diameter = 2*(new MinimumBoundingCircle(baseRacoon)).getRadius();
  baseTransformation.scale(0.95*width/(diameter*N_RACOONS_ROW),0.95*height/(diameter*N_RACOONS_COL));
  baseTransformation.rotate(PI);
  baseRacoon = baseTransformation.transform(baseRacoon);
  
  // Progressively add new racoons
  ArrayList<Geometry> racoons = new ArrayList<Geometry>();
  for(int i=0; i<N_RACOONS_ROW; i++) {
    for(int j=0; j<N_RACOONS_COL; j++) {
      // Gridify racoon
      int gridSize = (1 + i*i* width/400);
      Geometry racoon = gridify(baseRacoon, gridSize);
      // Simplify racoon
      float tolerance = width/300 * j;
      racoon = simplify(racoon, tolerance);
      println(i, j, gridSize, tolerance); 
      // Place racoon to the right position
      AffineTransformation t = new AffineTransformation();
      t.translate((width/N_RACOONS_ROW) * ((N_RACOONS_ROW-i-1)+0.5), (height/N_RACOONS_COL) * ((N_RACOONS_COL-j-1)+0.5));
      racoon = t.transform(racoon);
      racoons.add(racoon);
    }
  }
  
  
  beginRecord(SVG, "out/final.svg");
  
  background(255);
  noFill();
  stroke(0);    
  for(Geometry racoon : racoons) {
    for(int i=0; i<racoon.getNumGeometries(); i++) {
      LineString lines = (LineString) racoon.getGeometryN(i);
      beginShape();
      for(Coordinate coord : lines.getCoordinates()) {
        vertex((float) coord.x, (float) coord.y);
      }
      endShape();
    }
  }
  
  endRecord();
  println("Done");
  noLoop();
}
