//Version 3
th=2;                   //Thickness of case walls
w=192.96+3*th;          //Width of case (x dim)
b=110.76+3*th;          //Breadth of case (y dim)
h=50;                   //Height of case (z dim)
r=7;                    //Radius of case corners
hd1=4;                  //Mount key hole diameter 1
hd2=9;                  //Mount key hole diameter 2
hdist=6;                //Mount key hole distance
hw=2*r+2;               //Mount plate width
seth=1;                 //Screen edge thickness 
smth=6;                 //Screen thickness at mounts
smdw=(w-126.2)/2;       //Screen mount hole offset in width direction
smdb=(b-65.65)/2;       //Screen mount hole offset in breadth direction
smhd=3.5;               //Screen mount hole diameter
smw=smdw+2*smhd;        //Screen mount width
smoff=[0,1];            //Screen mount offset
grille_width=th;
grille_dist=6*th;
grille_count=8;        //Number of ventilation grilles    

$fn=25;
//returns a vector of the center of the circle at each corner 
//of a rounded square in the x-y plane
function corner_vectors(width, breadth, radius = 0) = 
    [
        [radius-width/2,radius-breadth/2,0],
        [width/2-radius,radius-breadth/2,0],
        [radius-width/2,breadth/2-radius,0],
        [width/2-radius,breadth/2-radius,0]];

module rounded_square(width,breadth,radius) {
    union() {
        square(size=[width-2*radius,breadth],center=true);
        square(size=[width,breadth-2*radius],center=true);
        
        for(cv = corner_vectors(width,breadth,radius)) {
            translate(v=cv) {
                circle(r=radius);
            }
        }
    }
}

module rounded_box_sides(width,breadth,radius,height,thickness) {
    linear_extrude(height=height) {
        difference() {
            rounded_square(width,breadth,radius);
            rounded_square(width-2*thickness,breadth-2*thickness,radius-thickness);
        }
    }
}

module key_hole(d1,d2,dist) {
    circle(d=d1);
    translate(v=[0,-1*dist,0]) {
        circle(d=d2);
    }
    translate(v=[0,-0.5*dist,0]) {
        square(size=[d1,dist], center=true);
    }
}

module rounded_square_triag_ring(width,breadth,radius,height,thickness) {
    difference() {
        rounded_box_sides(width,breadth,radius,height,thickness);
        linear_extrude(height=height,scale=[1-2*thickness/width,1-2*thickness/breadth]) {
            rounded_square(width,breadth,radius);
        }
    }
}



//Main box
difference() {
    //Rounded sides
    rounded_box_sides(w,b,r,h,th);
    //Ventilation grille
    translate (v=[-0.5*grille_dist*(grille_count-1),th-b/2,0]) {
        rotate(a = 90,v=[1,0,0]) {
            for (i = [0:grille_count-1]) {
                translate (v=[i*grille_dist,4*grille_width,-th]) {
                    //Ventilation grille
                    linear_extrude(height=3*th, twist=0, center=false) {
                        union() {
                            circle(d=grille_width);
                            translate(v=[-0.5*grille_width,0,0]) {
                                square(size=[grille_width,0.75*h]);
                            }
                            translate(v=[0,0.75*h,0]) {
                                circle(d=grille_width);
                            }
                        }
                    }
                }
            }
        }
    }
}

//Wall mount plates
linear_extrude(height=th) {
    difference() {
        rounded_square(w,b,r);
        square(size=[w-2*hw,b],center=true);
        translate(v=[0,hdist/2,0]) {
            for (cv = corner_vectors(w,b-hdist,r)) {
                translate(v=cv) {
                    key_hole(hd1,hd2,hdist);
                }
            }
        }
    }
}

//Screen support rim
translate(v=[0,0,h-th-seth]) {
    rounded_box_sides(w-2*th,b-2*th,r-th,th,3*th);
}
translate(v=[0,0,h-4*th-seth]) {
    rounded_square_triag_ring(w-2*th,b-2*th,r-th,3*th,3*th);
}

//Screen mounts
translate(v=[0,0,h-2*th-smth]) {
    linear_extrude(height=2*th) {
        union() {
            difference() {
                square(size=[w-2*smdw+4*smhd,b-2*th],center=true);
                square(size=[w-2*smdw-4*smhd,b],center=true);
                for (cv = corner_vectors(w-2*smdw,b-2*smdb,0))
                {
                    translate(v=cv+smoff) {
                        circle(d=smhd);
                    }
                }
            }
        }
    }    
}

