a = [1, 1, 1, 2, 2, 2, 2, 2, 4, 4, 4, 4]
plot, histogram(a, binsize=1, min=min(a), max=max(a)), xrange=[min(a), max(a)], psym=10, yrange=[0, 6]
;note: histogram itself only returns frequency

end
