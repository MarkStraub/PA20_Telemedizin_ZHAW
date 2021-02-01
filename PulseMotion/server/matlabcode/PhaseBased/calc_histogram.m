function [hist] = calc_histogram(delta)

% find biggest value changes - signal selection
frameNum = 100;
if (size(delta,3) < 200)
    frameNum = nF / 2;
end

Nmax = 10;
cols = zeros(Nmax, frameNum);
rows = zeros(frameNum, Nmax);

% get all positions of highest value changes
for frameIDX = 1:frameNum
    delta(:,:,frameIDX);
    [ rows(frameIDX,:), cols(:,frameIDX) ] = absoluteChanges(delta(:,:,frameIDX),delta(:,:,frameIDX + 1), Nmax);
end

% find the ones which occur the most
[ most_rows, most_cols ] = getMostOccurantElements(rows, cols, Nmax);

% peak detection
values = zeros(size(delta,3),Nmax);
average = zeros(size(delta,3),1);
for a = 1:size(delta,3)
    for b = 1:Nmax
        values(a,b) = delta(most_rows(b), most_cols(b), a);
    end
    average(a) = meanabs(values(a));
end

hist = average;

plot(average) 

end
%% absoluteChanges

function [ ind_row, ind_col ] = absoluteChanges(delta1, delta2, Nmax)
a = size(delta1,1);
b = size(delta1,2);
delta = zeros(a,b);
for x = 1:a
    for y = 1:b
        delta(x,y) = abs(delta1(x,y) - delta2(x,y));
    end
end
      
[ Avec, Ind ] = sort(delta(:),1,'descend');
max_values = Avec(1:Nmax);
[ ind_row, ind_col ] = ind2sub(size(delta),Ind(1:Nmax)); % fetch indices
end

%% getMostOccurantElements

function [ ind_row, ind_col ] = getMostOccurantElements(row, col, n)
a = size(row,1);
b = size(row,2);
positions = zeros(a*b,2);
count = 0;
for x = 1:a
    for y = 1:b
        count = count + 1;
        positions(count, 1) = row(x, y);
        positions(count, 2) = col(y, x);
    end
end

ind_row = zeros(n, 1);
ind_col = zeros(n, 1);

for i = 1:n
   m = mode(positions);
   size(m);
   ind_row(i) = m(1);
   ind_col(i) = m(2);
   positions(positions==m) = NaN;
end

end
