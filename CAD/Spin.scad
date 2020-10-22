/**
   File: Spin.scad
   Author: Lukas Severinghaus
   Date: October 21, 2020
   Purpose: Design files for Spin volume control.

   License:
   Copyright (C) 2020  Lukas Severinghaus
   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License version 3
   as published by the Free Software Foundation;
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

/**** View/Export options ****/
//Set to true to have pieces oriented for 3D printing.
//This inverts some pieces so they don't have to be inverted prior to slicing.
print = true;
//Set to 1 to view all parts 
//Set to 2 to view cross section of all parts
//Set to 3 to view outer piece only.
//Set to 4 to view inner top piece only.
//Set to 5 to view inner base piece only.
slice = 2;

//Circle resolution, set higher for better quality. 100-200 works well, higher than that increase rendering time.
cr = 100;

/**** Variables ****/
i2mm=25.4;
outer_r = 1.25*i2mm;//Radius of outer piece
outer_d = 3;//Depth of top outer edge
outer_wall = 3;//Wall thickness of outer piece
outer_h = 1.875*i2mm;
knob_hole = 6;//Knob diameter
knob_thick = 1.5; //Thickness of wall around knob
thread_hole = 7.7;
knob_height = 0.5*i2mm;

inner_r = 1.103*i2mm-0.5;//Radius of inner piece
inner_h = 1.8356 * i2mm + 2;//Height of inner piece
inner_top_d = 3; //Depth of top of inner
inner_thick = 3;

base_h = 0.75 * i2mm;//Height of the base
base_d = 2; //Thickness of the base
base_o = 2;//Overlap of the base
base_l = 5;//Overlap height
base_t = 0.25;//Overlap tolerance

tube_d = 2;//Thickness of flat part of inner hole
tube_r = 0.25 * i2mm; //Radius of inner hole
tube_t = 2;//Wall thickness of inner hole
tube_h = 0.7 * i2mm - tube_d;//Depth of inner hole
tube_hole_r = 3.85;

cable_r = 2.5;


module cut_plane(){
    translate([-50, 0, -0.1]) cube([100, 100, 100]);
}
module cut_plane_r(z){
    rotate([0, 0, z]) translate([-50, 0, -0.1]) cube([100, 100, 100]);
}
//Outer upper piece
module outer(){
    translate([0, 0, outer_h]) rotate([180, 0, 0]){
    union(){
        cylinder(outer_d, r1=outer_r, r2=outer_r, $fn=cr);
        difference(){
            cylinder(outer_h, r1=outer_r, r2=outer_r, $fn=cr);
            cylinder(outer_h+0.01, r1=outer_r-outer_wall, r2=outer_r-outer_wall, $fn=cr);
        }
        difference(){
            cylinder(knob_height+outer_d, r1=(knob_hole / 2) + knob_thick, r2=(knob_hole / 2) + knob_thick, $fn=cr);
            cylinder(knob_height+outer_d+0.01, r1=(knob_hole / 2), r2=(knob_hole / 2), $fn=cr);
        }
    }
}
}

module inner(){
  union(){
      difference(){
          //Outer cylinder
          cylinder(inner_h-base_h, r1=inner_r, r2=inner_r, $fn=cr);
          //Inner cylinder cut
          translate([0, 0, -0.1]) cylinder(inner_h - inner_top_d + 0.1 - base_h, r1 = inner_r - inner_thick, r2=inner_r-inner_thick, $fn=cr);
          //Top hole
          cylinder(inner_h + 0.3 - base_h, r1=tube_r, r2=tube_r, $fn=cr);
      }
      //Encoder slot/hole
      translate([0, 0, inner_h - (tube_h + tube_d) - base_h]) difference(){
      translate([0, 0, 0]) cylinder(tube_h+tube_d, r1=tube_r+tube_t, r2=tube_r+tube_t, $fn=cr);
      translate([0, 0, -0.1]) cylinder(tube_d + 0.2, r1=tube_hole_r, r2=tube_hole_r, $fn=cr);
      translate([0, 0, tube_d]) cylinder(tube_h+0.1, r1=tube_r, r2=tube_r, $fn=cr);    
          
      }
      
  }
}

module inner_base(){
    difference(){
    union(){
    cylinder(base_h-0.1, r1=inner_r, r2=inner_r, $fn=cr);
    cylinder(base_h + base_l, r1=inner_r - inner_thick-base_t, r2=inner_r - inner_thick-base_t, $fn=cr);
    }
    //Inner cylinder cut
    translate([0, 0, base_d]) cylinder(base_h - base_d + 0.1+20, r1 = inner_r - inner_thick-base_o, r2=inner_r-inner_thick-base_o, $fn=cr);
    //Cable hole
    translate([15, 0, 2.5]) rotate([0, 90, 0]) cylinder(100, r1=cable_r, r2=cable_r, $fn=cr);
          //Cable hole slot
    translate([15, -1 * cable_r, -0.1]) cube([100, cable_r*2, cable_r+0.1]);
    translate([10, 0, -0.1]) cylinder(10, r1=0.3*i2mm, r2=0.3*i2mm, $fn=cr);
    }
}

if(slice == 1){
    translate([0, 0, base_h]) inner();
    inner_base();
    translate([0, 0, 0.125 *i2mm + 2]) outer();
}else if(slice == 2){
    difference(){
        translate([0, 0, base_h]) color([0, 1, 0]) inner(); cut_plane();
    }
    difference(){
        color([0, 0, 1]) inner_base();
        cut_plane_r(0);
    }
    difference() {
        translate([0, 0, 0.125 *i2mm + 2]) color([1, 0, 0]) outer();
        cut_plane_r(0);
    }

}else if(slice == 3){
    rotate([0, print ? 180 : 0, 0]) outer();
}else if(slice == 4){
    rotate([0, print ? 180 : 0, 0]) inner();
}else if(slice == 5){
    inner_base();
}


