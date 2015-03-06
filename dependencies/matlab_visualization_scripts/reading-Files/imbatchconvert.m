function options = imbatchconvert(src_dir, idsrc, dst_dir, iddst, dir_recurse, options)

% options = imbatchconvert(src_dir, idsrc, dst_dir, iddst, dir_recurse, options)
%
% DESC:
% converts the images inside folder dirname (and recurisvely its
% subfolders) from format idsrc to format iddst
%
% AUTHOR
% Marco Zuliani - zuliani@ece.ucsb.edu
%
% VERSION
% 1.0.2
%
% INPUT:
% src_dir		= source directory name
% idsrc         = input format (if empty consider all the known formats)
% dst_dir       = destination directory name (default = source dir)
% iddst         = destination format
% dir_recurse   = true to recurse inside the directory (default false)
% options       = options for the conversion
%
%                 'rgb2gray'    {true, false}   converts to gray level if
%                                               the original is RBG
%                                               (default false)
%
%                 'Scaling'     scaling         scale image
%                                               (default 1.0)
%
%                 'Func'        function_name   function that operates on 
%                                               the image. Must be in the 
%                                               form of: 
%
%                                               J = function_name(I, FuncPar)
%
%                 'FuncPar'     parameters      parameters of the function 
%                                               that operates on the image. 
%                                               (default empty)
%
%                 'Verbose'     {true, false}   enable verbose output
%                                               (default false)
%
%                 'NameSuffix'  string          add the suffix to the name
%                                               of the converted image
%                                               (default empty)
% OUTPUT:
% options       = set and default options
%
% EXAMPLE:
%
% % cropping of the images
% 
% options.Func = 'imcrop';
% options.FuncPar = [10 10 40 40];
% options.Verbose = true;
% options.NameSuffix = '_cropped';
% src_dir = '/Users/zuliani/Research/TestImages/Wall/originals';
% dst_dir = '/Users/zuliani/Research/TestImages/Wall/cropped';
% idsrc = 'ppm';
% iddst = 'jpg';
% options = imbatchconvert(src_dir, idsrc, dst_dir, iddst, true, options);

% HISTORY
% 1.0.0        12/02/07 - Initial version
% 1.0.1        28/05/08 - added options field
% 1.0.2        29/05/08 - added Func and FuncPar option

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 4
    dir_recurse = false;
end;

if isempty(dst_dir)
    dst_dir = src_dir;
end;

if isempty(idsrc)
    % get the formats recognized by matlab
    formats = imformats;

    % form the regular expression
    idsrc = '';
    for h = 1:numel(formats)
        for k = 1:numel(formats(h).ext)
            idsrc = sprintf('%s/.%s|', idsrc, char(formats(h).ext{k}));
        end;
    end
    idsrc = idsrc(1:end-1);

end;

if iddst(1) ~= '.'
    iddst = sprintf('.%s', iddst);
end;

% options

if nargin < 5
    options = [];
end;

if ~isfield(options, 'Verbose')
    options.Verbose = false;
end;

if ~isfield(options, 'rgb2gray')
    options.rgb2gray = false;
end;

if ~isfield(options, 'NameSuffix')
    options.NameSuffix = [];
end;

if ~isfield(options, 'Scaling')
    options.Scaling = 1.0;
end;

if ~isfield(options, 'Func')
    options.Func = [];
end;

if ~isfield(options, 'FuncPar')
    options.Func = [];
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Retrieve files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f = get_file_list(src_dir, idsrc, dir_recurse);

if numel(f) == 0
    warning('imbatchconvert:NoFiles','No files to process')
    return
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Perform conversion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for h = 1:numel(f)

    output_filename = fullfile(dst_dir, ...
        sprintf('%s%s%s', f(h).name, options.NameSuffix, iddst));

    % skip if the output filename already exists
    if ( exist(output_filename, 'file') )
        if options.Verbose
            fprintf('\nSkipping file %s because destination already exists', f(h).filename);
        end;
    else

        if options.Verbose
            fprintf('\nProcessing file %s', f(h).name);
        end;

        % read in
        try
            I = imread(f(h).filename);
            if options.Verbose
                fprintf(' [in]');
            end;
        catch
            warning('imbatchconvert:CouldNotReadImage','Could not read image %s\n (reason : %s)', f(h).filename, lasterr);
            continue;
        end;

        % process
        if options.rgb2gray
            try
                if size(I, 3) == 3
                    if options.Verbose
                        fprintf(' [rgb2gray]');
                    end;
                    I = rgb2gray(I);
                end;
            catch
                warning('imbatchconvert:CouldNotConvert2Gray', 'Could not convert to gray level image %s\n (reason : %s)', f(h).filename, lasterr);
                continue;
            end;
        end;

        if abs(options.Scaling - 1.0) > eps
            try
                if options.Verbose
                    fprintf(' [scaling]');
                end;
                I = imresize(I, options.Scaling, 'bicubic');
            catch
                warning('imbatchconvert:CouldNotScale', 'Could not scale the image\n (reason : %s)', lasterr);
                continue;
            end;
        end;
        
        if ~isempty(options.Func)
            try
                if options.Verbose
                    fprintf(' [%s]', options.Func);
                end;
                eval(sprintf('I = %s(I, options.FuncPar);', options.Func));
            catch
                warning('imbatchconvert:CouldNotApplyFunction', 'Could not apply the function to the image\n (reason : %s)', lasterr);
            end
        end;

        % write out
        try
            imwrite(I, output_filename);
            if options.Verbose
                fprintf(' [out]');
            end;
        catch
            warning('imbatchconvert:CouldNotWriteclearImage','Could not write image %s\n (reason : %s)', output_filename, lasterr);
            continue;
        end;

    end;

end;

if options.Verbose
    fprintf('\nDone\n');
end;

return