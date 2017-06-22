setwd('~/Desktop/nicheNet')  #shouldn't need to set working directory if running script from base dir
library(raster)
library(spatial.tools)
library(rgdal)

######NOTE YOU NEED TO MAKE SURE NULL VALUES ARE WHAT YOU WANT #########
#######SET NULLS USING THE LOOP BELOW############

#for (r in list){
	#raster <- raster(r)
	#print(raster)
	#raster[is.na(raster)] <- 0
	#print(raster)
	#writeRaster(raster,filename=paste0(r,"nullzero.asc"))
#}

#read in known occurence points
read.csv("./data/Locs.csv")->points 
points[,2:3] -> points
colnames(points) <- c("x", "y")
unique(points) -> points
npoints<- nrow(points)
head(points)
npoints

#list feature rasters
list <- list.files(path="./data/layers", pattern="*.asc")
nlist <- length(list)
list
nlist
na <- NA
#read in features
setwd("./data/layers")
Stack <- stack(list)
res <- res(Stack)
ras<- raster(list[1])
buf<- unlist(res[1]*5)  #change the 5 to whatever radius you want for punches
Stack
setwd("../")



#make buffer size using matrix then make center point 0 # represents the center cell you are inputing -- this is how you adjust punch size
buffer <- matrix(1, 27, 27)
buffer[14,14] <- 0
buffer
list.files()
#make output folder for positive occurences
dir.create('./test_Set')
dir.create("./test_Set/true")
truecells <- c()

#loop through occurences
for (i in 1:npoints){
	cell<-cellFromXY(object=Stack,xy=points[i,])# get the cell number
	cells <- adjacent(Stack,cell,directions=buffer,pairs=T,include=T)
	r <- rasterFromCells(Stack, cells, values=T)
	punch <- crop(Stack, r)
	print(punch)
	dir.create(noquote(paste0("./test_Set/true/",cell)))
	writeRaster(punch, filename=paste0("test_Set/true/",cell,"/",cell,".asc"), bylayer=T, overwrite=T)
	print(noquote(paste0(cell,".asc")))
	truecells <- c(truecells,cell)
}

#generate a random distribution of points within study region
background <- sampleRandom(ras, 1000, cells=T, xy = TRUE, sp=F, na.rm = TRUE)  #set number of reps
write.csv(background[,1:3],"./test_Set/background_sampling.csv")
background[,1] -> background
background<- data.frame(background)
unique(background) -> background
nbackground<- nrow(background)
nbackground

# make output folder for background 
dir.create("./test_Set/false")

#iterate through background points, first checking that they were not already included in the true list
for (i in 1:nbackground) {
	cell <- background[i,1]
			if (cell %in% truecells){
			print(paste0(cell," is present in true dataset"))
			} else {
	cells <- adjacent(Stack,cell,directions=buffer,pairs=T,include=T)
	cells
	r <- rasterFromCells(Stack, cells, values=T)
	punch <- crop(Stack, r)
	print(punch)
	dir.create(noquote(paste0("./test_Set/false/",cell)))
	writeRaster(punch, filename=paste0("./test_Set/false/",cell,"/",cell,".asc"), bylayer=T)
	print(noquote(paste0(cell,".asc")))
}}

	
	
	
	
	
