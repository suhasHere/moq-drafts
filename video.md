Simulcast

SVC
-----
GOP per Stream
    another dimension of stream mu
    Group is time based chunking
SVC
 SRST - 1 QUIC Stream for all layers 
 MRST - 1 QUIC Stream per layer

Track 
   all layers in one track
   each layer gets its own track 
        how to express gropp/objects across tracks

ratio is close- pframes in enchamcement layer
decoders can decode     
    av1 , 265, 266 -> simplify scalability schemes  

Base layer 
   I Frame
   180p
Enhancement layer
   1080p, can 
   p frames (may become an i-frame)   

all layers in one track
   one group must have all layers for a certain time
   can possibly contain multiple i-frame
   can express depdndecies within media container and not at at Moq Level


base layer sync points
    base layer 
    LRR - refresh me to fix the error
       next 4k frame depends only on the base layer and marked with base layer sync flag set
       happens in the pixel domain (all reference happens to raw buffer)

Gradual decoder refresh
    split I frame into multiple p-frames 
    in h264/h265 there is  sei message that says how long the GDR frames happen
    marking them with the same Priority
    very 

k-SVC
    simulcast but don't simulcast the i-frame
    enhacement layers are sent as a p-frames

I - P - I
L0  L1  L2   

I - P - I
L0  L1  L2   



Things that do have same timestamp MUST be in the same group

