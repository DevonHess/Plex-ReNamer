{ const { Set Options }
	{ Serial = True; { Serialize or Detect # }
	{ Start = 1; { Begin at Episode # }
	{ Steps = 1; { # of Steps Between }
	{ Parts = 1; { Multi File Episodes }
	{ Multi = False; { Multi Episode Files }
	{ ForceSeason = ''; { Specify or Detect # }
	{ EpisodePad = 2; { Leading Zeros to Length }
	{ SeasonPad = 2; { Leading Zeros to Length }
	{ SubLanguage = 'eng'; { Subtitle Language }
{ {$INCLUDE 'Plex.pas'}

var
	i: Integer;
	Show: WideString;
	Season: WideString;
	Episode: WideString;
	Suff: WideString;
	Base: WideString;
	Ext: WideString;
	SeasonFolder: TWideStringArray;
	LastSeason: WideString;
	LastEpisode: WideString;

begin
	Base := ReplaceRegEx(WideExtractFileName(FilePath),
		'^(.*?)((\.'+SubLanguage+')?\'+WideExtractFileExt(FilePath)
		+')$', '$1', False, True);
	Season := WideExtractFileName(WideExtractFileDir(FilePath));
	SeasonFolder := WideSplitString(Season, ' ');

	{ Set Season # }
	if SeasonFolder[0]='Season' then
		begin
			Show := WideExtractFileName(
				WideExtractFileDir(
				WideExtractFileDir(FilePath)));
			Season := ReplaceRegEx(SeasonFolder[1],
				'.*?0*(\d+)\D*$', '$1', False, True);
		end
	else if SeasonFolder[0]='Specials' then
		begin
			Show := WideExtractFileName(
				WideExtractFileDir(
				WideExtractFileDir(FilePath)));
			Season := '0';
		end
	else
		begin
			Show := Season;
			Season := '1';
		end;

	if ForceSeason<>'' then
		begin
			Season := ForceSeason;
		end;

	{ Reset Episode # on Season Change }
	if Season<>LastSeason then
		begin
			i := 0;
			LastEpisode := '';
		end;
	LastSeason := Season;

	{ Adjust for Same-name Files }
	if (LastEpisode<>'') and (Base<>LastEpisode) then
		begin
			i := i+1;
		end;
	LastEpisode := Base;

	{ Serialize or Detect Episode # }
	if Serial=True then
		begin
			Episode := IntToStr((i/Parts)*Steps+Start);
		end
	else
		begin
			Episode := ReplaceRegEx(Base,
				'(\(.*?\)|\[.*?\]|\{.*?\})'
				+'|(\bse?\d+|season.*?\d+)|par(ts)?\d+'
				+'|(\d+p)|(v\d+)|(19|20)\d\d|[hx]\.?\d{3}|DD.2\.0',
				'', False, True);
			Episode := ReplaceRegEx(Episode,
				'.*?0*(\d+)\D*$', '$1', False, True);
		end;

	Suff := IntToStr(StrToInt(Episode)+Steps-1);

	{ Add Leading Zeros }
	while Length(Season) < SeasonPad do
		begin
			Season := '0'+Season;
		end;
	while Length(Episode) < EpisodePad do
		begin
			Episode := '0'+Episode;
		end;
	while Length(Suff) < EpisodePad do
		begin
			Suff := '0'+Suff;
		end;

	{ Add Following Episodes or Parts }
	if (Multi=True) and (Parts<=1) then
		begin
			Suff := '-e'+Suff;
		end
	else
		begin
			if (Parts>1) then
				begin
					Suff := ' - pt'+IntToStr(i mod Parts+1);
				end
			else
				begin
					Suff := '';
				end;
		end;

	{ Add Language for Subtitles }
	Ext := WideExtractFileExt(FilePath);
	if (Ext='.srt') or (Ext='.smi')
	or (Ext='.ssa') or (Ext='.ass') or (Ext='.vtt') then
		begin
			Ext := '.'+SubLanguage+Ext;
		end;

	FileName := Show+' - s'+Season+'e'+Episode+Suff+Ext;
end.
