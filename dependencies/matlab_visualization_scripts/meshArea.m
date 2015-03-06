function area = meshArea(mesh)

% area = meshArea(mesh)
%
% calculates surface area of mesh
%
% mesh is a data structure - mesh.vertices mesh.triangles
%
% Copyright : This code is written by Ajmal Saeed Mian {ajmal@csse.uwa.edu.au}
%              Computer Science, The University of Western Australia. The code
%              may be used, modified and distributed for research purposes with
%              acknowledgement of the author and inclusion this copyright information.
%
% Disclaimer : This code is provided as is without any warrantly.

area = 0;
for polNo = 1 : length(mesh.triangles)
    vertexNo = mesh.triangles(polNo,:);
    vertices = mesh.vertices(vertexNo,:);
    area =area + 0.5 * norm(cross((vertices(2,:)-vertices(1,:)), (vertices(3,:)-vertices(1,:))));
end