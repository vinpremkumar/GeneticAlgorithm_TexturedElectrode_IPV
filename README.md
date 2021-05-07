# GeneticAlgorithm_TexturedElectrode_IPV
Using evolutionary algorithm to model surface texture of electrodes in indoor photovoltaics (IPVs). It creates a complimentary grating pattern on the top and bottom electrodes. The transport layer is designed as a buffer around the electrodes and the interspace is filled by the active layer such that the active layer thickness at any position is the same regardless of the grating pattern. The source code has the ability to be edited to produce single electrode grating pattern or even mirror the grating pattern on both the electrodes (active layer thickness will vary in this case with position).

# Steps:
1) Generate random polygons
2) Cross-breeding generated polygons
3) Optimize the inter-grating spacing
4) Deposit buffer layer
5) Calculate optical absorption (cost-function)

# Generating Polygons
* cannot be made by making random points since the order of connection cannot be found in high vertex point cases.
* better way is to limit the points inside a circle and control the angle between the faces of the polygon.
* This way can be used to make both convex and concave polygons. I wanted to limit my structures to convex structures for the initial population since concave structures will arise from interbreeding the convex structures later on.
* The size of the polygon structure was controlled by the radii of the ellipse.

Omit unbalanced structures:
* Since these are surface grating patterns, to make it a little practical, unbalanced structures (structures which does not have its center of gravity falling within its base) were omitted.
* This was achieved by calculating the centroid of the polygon and checking if it falls within the base (along x-axis).

![image](https://user-images.githubusercontent.com/49431830/117394326-eb8b5480-af30-11eb-9008-725796b0b5d1.png)

# Cross-over
Cross-over consists of 4 steps: Masking, Meshing, Cross-over, and Mixing.

* *Masking:* It is for solidifying the necessary polygon so that we can work on it like an image. Basic working: Colors the polygon (and inside area) white, and outside boundary black. 
  * Note that we have to keep the size of the polygon boundary the same for the cross-breeding process to be accurate.

![image](https://user-images.githubusercontent.com/49431830/117394078-6ef87600-af30-11eb-930d-693ba9185d50.png)

* *Meshing:* I had divided the polygon into 4x4 sub-structures. I had tested with 5x5 and 3x3 but 4x4 division provided the best output.

![image](https://user-images.githubusercontent.com/49431830/117394159-97807000-af30-11eb-9d9a-af49a3da63a3.png)

* *Cross-over:* Crossover method is the way chromosomes from the parent population (thickness are converted to binary and are referred to as population) are passed on to the child. 
Each parent has a 50% chance to give their chromosome to the child.

  * In uniform cross over, each bit has a 50% probability to be obtained from parent1 or parent 2.
  * In k-point cross over, the entire binary gene is split into sections. Each parent has a 50% probability to donate its chromosomes to the section.

![image](https://user-images.githubusercontent.com/49431830/117393889-0a3d1b80-af30-11eb-9286-4171be2583f4.png)

* *Mixing:* A random 4x4 matrix of 1s (red) and 2s (blue) was first created. In the matrix position where 1s were filled, the parent1 polygon's sub-structures were pasted. In the matrix position where 2s were filled, the parent2 polygon's sub-structures (also called chromosomes) were pasted. Thus, a new child polygon was made.
  * Holes made inside the polygon that are too small (<1 nm), sharp overlaps, hanging structures (structures that are not attached to the main body of the polygon), were coded to be ignored since they will provide impractical structures.
   *Mutations in the chromosomes can also occur. a value 3 in the randomized 4x4 matrix denote that a mutation had occurred. Mutation rate is pretty low but is significant. To mimic this process, I generated a new random polygon, and its chromosome was input where the mutation had occurred.

![image](https://user-images.githubusercontent.com/49431830/117393034-2f308f00-af2e-11eb-9b4d-2ed251e51d44.png)

# Polygon re-construction:
The reconstruction of binary image to vertices and edges was done using Moore-neighborhood tracing algorithm with the modified Jacob's stopping criteria.
Since the number of vertices is very large using the Moore-neighborhood tracing algorithm, I used the Ramer–Douglas–Peucker algorithm under reducepoly() function in MATLAB to obtain a computationally finite number of vertices.

![image](https://user-images.githubusercontent.com/49431830/117393311-d1e90d80-af2e-11eb-91fa-ed637befb7f0.png)

# Spacing between grating patterns:
* The spacing between the gratings was also optimized using GA technique. 
* It is similar to the thickness optimization from the previous presented work. Only difference is that instead of layer thickness (which is an integer number), I optimized the interspacing between gratings (which is also an integer number).

# Depositing the transport layer:
* It is not as simple as enlarging the surface texture. In fact, if it is done that way, it would not be uniformly thick on all sides.
* In other to enlarge an image with its center the same, we need to increase the size of the edges, then push them out by a specific margin. After this, we have to connect the edges again. I had utilized smooth (rounded squared) connecting as it provided the most stable results.

# Construct TCAD structure (Matlab interconnectivity to Lumerical, FDTD)

![image](https://user-images.githubusercontent.com/49431830/117394501-3e650c00-af31-11eb-966a-e312f696713a.png)

# Improved optical efficiency:
**+3.46 %**

# Ref: 
https://doi.org/10.3390/en13071726 (https://github.com/gcunhase/GeneticAlgorithm-SolarCells)

https://doi.org/10.1016/j.nanoen.2019.01.061

# Requirements:
1) Lumerical, FDTD software
2) cprintf.m

# Run:
Run the 'Main.m' file

# Contact:
vinpremkumar@gmail.com

# License:
Licensed under GNU AFFERO GENERAL PUBLIC LICENSE Version 3, 19 November 2007. Check the 'LICENSE.txt' file for further details
