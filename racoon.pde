import java.util.stream.Collectors;
import processing.svg.*;

int N_RACOONS_ROW = 1;
int N_RACOONS_COL = 1;

void setup() {
  size(720, 720);
  
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
  
  // Transforms base racoon to base shape
  AffineTransformation baseTransformation = new AffineTransformation();
  Point centroid = baseRacoon.getCentroid();
  baseTransformation.translate(-centroid.getX(),-centroid.getY());
  double diameter = 2*(new MinimumBoundingCircle(baseRacoon)).getRadius();
  baseTransformation.scale(0.95*width/(diameter*N_RACOONS_ROW),0.95*height/(diameter*N_RACOONS_COL));
  baseTransformation.rotate(PI);
  
  // Progressively add new racoons
  ArrayList<Geometry> racoons = new ArrayList<Geometry>();
  for(int i=0; i<N_RACOONS_ROW; i++) {
    for(int j=0; j<N_RACOONS_COL; j++) {
      println("Processing racoon: ", racoons.size()+1, " / ", N_RACOONS_ROW*N_RACOONS_COL);
      float iTolerance = 0.001 * log(map(i, 0, N_RACOONS_ROW-1, 1, exp(1)));
      float jTolerance = 0.001 * log(map(j, 0, N_RACOONS_COL-1, 1, exp(1)));
      Geometry racoon = VWSimplifier.simplify(baseRacoon, iTolerance);
      racoon = DouglasPeuckerSimplifier.simplify(racoon, jTolerance);
      
      AffineTransformation t = new AffineTransformation(baseTransformation);
      t.translate((width/N_RACOONS_ROW) * (i+0.5), (height/N_RACOONS_COL) * (j+0.5));
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
      Polygon inner = (Polygon) racoon.getGeometryN(i);
      beginShape();
      for(Coordinate coord : inner.getExteriorRing().getCoordinates()) {
        vertex((float) coord.x, (float) coord.y);
      }
      endShape();
      for(int j=0; j<inner.getNumInteriorRing(); j++) {
        beginShape();
        for(Coordinate coord : inner.getInteriorRingN(j).getCoordinates()){
          vertex((float) coord.x, (float) coord.y);
        }
        endShape();
      }
    }
  }
  endRecord();
  println("Done");
  noLoop();
}
