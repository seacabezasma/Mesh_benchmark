/**
 * Flock of Boids
 * by Jean Pierre Charalambos.
 * 
 * This example displays the 2D famous artificial life program "Boids", developed by
 * Craig Reynolds in 1986 and then adapted to Processing in 3D by Matt Wetmore in
 * 2010 (https://www.openprocessing.org/sketch/6910#), in 'third person' eye mode.
 * Boids under the mouse will be colored blue. If you click on a boid it will be
 * selected as the scene avatar for the eye to follow it.
 *
 * Press ' ' to switch between the different eye modes.
 * Press 'a' to toggle (start/stop) animation.
 * Press 'p' to print the current frame rate.
 * Press 'm' to change the mesh visual mode.
 * Press 't' to shift timers: sequential and parallel.
 * Press 'v' to toggle boids' wall skipping.
 * Press 's' to call scene.fitBallInterpolation().
 */

import frames.input.*;
import frames.input.event.*;
import frames.primitives.*;
import frames.core.*;  
import frames.processing.*;

Scene scene;
int flockWidth = 1280;
int flockHeight = 720;
int flockDepth = 600;
int[][] vertex_list = {{-3, 2, 0},{3, 0, 0},{-3, 0, 2},{-3, -2, 0}};
int[][] face_list = {{0, 1, 2},{2, 1, 0},{3, 1, 0},{0, 2, 3}};
int[] vertex_vertex_list = {0, 1, 2, 2, 1, 0, 3, 1, 0, 0, 2, 3};
boolean avoidWalls = true, retained = false, face_mesh = true;

//Additional info used by Boid_retained. It MUST match with info within Boid class as well.
float sc = 3; // scale factor for the render of the boid
int ret_kind = TRIANGLES, vertex;
//ret_kind = POINTS;
PShape ret_shape;

// visual modes
// 0. Faces and edges
// 1. Wireframe (only edges)
// 2. Only faces
// 3. Only points
int mode = 2;

int initBoidNum = 900; // amount of boids to start the program with
ArrayList<Boid> flock;
ArrayList<Boid_retained> ret_flock;
Node avatar;
boolean animate = true;

void setup() {
  size(1000, 800, P3D);
  scene = new Scene(this);
  scene.setBoundingBox(new Vector(0, 0, 0), new Vector(flockWidth, flockHeight, flockDepth));
  scene.setAnchor(scene.center());
  Eye eye = new Eye(scene);
  scene.setEye(eye);
  scene.setFieldOfView(PI / 3);
  //interactivity defaults to the eye
  scene.setDefaultGrabber(eye);
  scene.fitBall();
  
  //crete a shape object containing vertex data used by Boid_retained

  // create and fill the list of boids
  flock = new ArrayList();
  ret_flock = new ArrayList();
  
  if(retained){
    
    // uncomment to draw boid axes
    //scene.drawAxes(10);
    strokeWeight(2);
    stroke(color(0, 255, 0));
    fill(color(255, 0, 0, 125));
  
    // visual modes
    switch(mode) {
    case 1:
      noFill();
      break;
    case 2:
      noStroke();
      break;
    case 3:
      strokeWeight(3);
      ret_kind = POINTS;
      break;
    }
    
    
    ret_shape = createShape();
    ret_shape.beginShape(ret_kind);
    
    //===================================================
    //Comment to disable data structures representation
    if(face_mesh){
      for(int i=0; i<face_list.length; i++){
        for(int j=0; j<face_list[i].length; j++){
          vertex = face_list[i][j];
          ret_shape.vertex(vertex_list[vertex][0] * sc, vertex_list[vertex][1] * sc, vertex_list[vertex][2] * sc);
        }
      }
    } else{
      for(int k=0; k<vertex_vertex_list.length; k++){
        vertex = vertex_vertex_list[k];
        ret_shape.vertex(vertex_list[vertex][0] * sc, vertex_list[vertex][1] * sc, vertex_list[vertex][2] * sc);
      }
    }
    //====================================================
    
    //Uncomment to enable original representations
    /*
    ret_shape.vertex(3 * sc, 0, 0);
    ret_shape.vertex(-3 * sc, 2 * sc, 0);
    ret_shape.vertex(-3 * sc, -2 * sc, 0);
  
    ret_shape.vertex(3 * sc, 0, 0);
    ret_shape.vertex(-3 * sc, 2 * sc, 0);
    ret_shape.vertex(-3 * sc, 0, 2 * sc);
  
    ret_shape.vertex(3 * sc, 0, 0);
    ret_shape.vertex(-3 * sc, 0, 2 * sc);
    ret_shape.vertex(-3 * sc, -2 * sc, 0);
  
    ret_shape.vertex(-3 * sc, 0, 2 * sc);
    ret_shape.vertex(-3 * sc, 2 * sc, 0);
    ret_shape.vertex(-3 * sc, -2 * sc, 0);*/
    
    ret_shape.endShape();
    
    
    
    for (int i = 0; i < initBoidNum; i++)
      ret_flock.add(new Boid_retained(new Vector(flockWidth / 2, flockHeight / 2, flockDepth / 2), ret_shape));
  }
  else
  for (int i = 0; i < initBoidNum; i++)
    flock.add(new Boid(new Vector(flockWidth / 2, flockHeight / 2, flockDepth / 2)));
}

void draw() {
  background(0);
  ambientLight(128, 128, 128);
  directionalLight(255, 255, 255, 0, 1, -100);
  walls();
  // Calls Node.visit() on all scene nodes.
  scene.traverse();
}

void walls() {
  pushStyle();
  noFill();
  stroke(255);

  line(0, 0, 0, 0, flockHeight, 0);
  line(0, 0, flockDepth, 0, flockHeight, flockDepth);
  line(0, 0, 0, flockWidth, 0, 0);
  line(0, 0, flockDepth, flockWidth, 0, flockDepth);

  line(flockWidth, 0, 0, flockWidth, flockHeight, 0);
  line(flockWidth, 0, flockDepth, flockWidth, flockHeight, flockDepth);
  line(0, flockHeight, 0, flockWidth, flockHeight, 0);
  line(0, flockHeight, flockDepth, flockWidth, flockHeight, flockDepth);

  line(0, 0, 0, 0, 0, flockDepth);
  line(0, flockHeight, 0, 0, flockHeight, flockDepth);
  line(flockWidth, 0, 0, flockWidth, 0, flockDepth);
  line(flockWidth, flockHeight, 0, flockWidth, flockHeight, flockDepth);
  popStyle();
}

void keyPressed() {
  switch (key) {
  case 'a':
    animate = !animate;
    break;
  case 's':
    if (scene.eye().reference() == null)
      scene.fitBallInterpolation();
    break;
  case 't':
    scene.shiftTimers();
    break;
  case 'p':
    println("Frame rate: " + frameRate);
    break;
  case 'v':
    avoidWalls = !avoidWalls;
    break;
  case 'm':
    mode = mode < 3 ? mode+1 : 0;
    break;
  case ' ':
    if (scene.eye().reference() != null) {
      scene.lookAt(scene.center());
      scene.fitBallInterpolation();
      scene.eye().setReference(null);
    } else if (avatar != null) {
      scene.eye().setReference(avatar);
      scene.interpolateTo(avatar);
    }
    break;
  }
}
