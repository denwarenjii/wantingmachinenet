#!/usr/bin/fish

set files ../banners/uncompressed/*

echo -e "Compressing " (count $files) " banners.\n"

for abs_file_path in $files
    set file (basename $abs_file_path)

    set splits (string split '.' $file)
    set base_file $splits[1]
    set extension $splits[2]

    if string match --quiet --regex "(?i)gif" $extension

        set outfile ../banners/compressed/$(string join "" $base_file "_compressed." $extension)

        #use gifscile to compress gifs
        gifsicle --colors=16 -O3 --lossy=100 -o $outfile $abs_file_path

    else if string match --quiet --regex "(?i)png" $extension

        #use imagemagick to compress pngs to jpg
        set outfile ../banners/compressed/$(string join "" $base_file "_compressed." "jpg")

        magick  $abs_file_path -strip -interlace JPEG -gaussian-blur 0.05 -quality 0% $outfile

    end
end

echo -e "\nDone. Printing diff.\n"

# fish doesn't have process substitution like bash ... 
diff (du -sh ../banners/compressed/ | psub) (du -sh ../banners/uncompressed | psub)
