# export_fig
EXPORT_FIG exports data from MATLAB .fig file to hdf5 file
      EXPORT_FIG(figname,varargin)
      Input:
      - figname     string of .fig filename with extension removed (e.g.
      'example1' for a figure named 'example1.fig')  Include path if
      figure is not in current folder.  Optional second argument is a
      string containing a description of the figure file, e.g. 'Figure N
      from J. Doe, et al, 2017.'
