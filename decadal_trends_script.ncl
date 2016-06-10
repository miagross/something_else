;***********************************************************
;;*********Script to calculate 3 moments and plot***********
;;*****************box & whisker plots**********************
;***********************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

;***********************************************************

begin

;plot_vars	= new((/2/),graphic)			;initialise plot array (2 separate plots for TX and TN)

ClimVars 	=(/"TX","TN"/)
  
;;loop through years
TenYrs	=(/"1979-1988","1980-1989","1981-1990","1982-1991","1983-1992","1984-1993","1985-1994","1986-1995","1987-1996",\
	"1988-1997","1989-1998","1990-1999","1991-2000","1992-2001","1993-2002","1994-2003","1995-2004","1996-2005",\
	"1997-2006","1998-2007","1999-2008","2000-2009","2001-2010","2002-2011","2003-2012","2004-2013","2005-2014"/)
		
do ivar=0, dimsizes(ClimVars)-1
  var = ClimVars(ivar)

  ;;;set-up output
  ;plotfile = "/srv/ccrc/data40/z5026024/data/Plots/boxplot_test"
  plotfile = "boxplot_"+var+"_test"
  wks_type = "png"
  wks = gsn_open_wks(wks_type,plotfile)

  ;;;set up arrays for x- and y-values
  xVals=ispan(1,dimsizes(TenYrs),1)			;numeric vector, replace the x-tick labels by TenYrs string in plot
  yVals = new ((/dimsizes(TenYrs),5/), "float", -999.)
  
  minVal = new(dimsizes(TenYrs),"float")
  maxVal = new(dimsizes(TenYrs),"float")
  
  do iYrs = 0, dimsizes(TenYrs)-1
   Yrs = TenYrs(iYrs)
   
   print((iYrs+": ")+Yrs)
   

 
  ;***********************************************************
  ;;*********************Read-in input************************
  ;***********************************************************
 
  InDataDir1 = "/srv/ccrc/data40/z5026024/data/running_window_files/"
  InData1 = InDataDir1+"HadGHCND_"+var+"_"+Yrs+"_anoms_masked_smoothed.nc"
  
  file1 = addfile(InData1,"r")
 
   if (var.eq."TX") then
    data1 = file1->TX_anoms
   end if
   if (var.eq."TN") then
    data1 = file1->TN_anoms
   end if


  print ("Data read in - start calculations")
  
  
  anom1 = data1
  


  ;***********************************************************
  ;;*******************Calculate statistics********************
  ;************************for boxplot*************************  
   
   ;;;calculate statistics
   opt		= True
   opt@PrintStat = False
   anom1_stats	= stat_dispersion(anom1,opt)		;calculates statistics
   
   ;;;extract stats 
   yVals(iYrs,0)	= anom1_stats(23)	;lower 1.0% of data, 1th percentile
   yVals(iYrs,1)	= anom1_stats(6)	;lower quartile
   yVals(iYrs,2)	= anom1_stats(0)	;mean value
   yVals(iYrs,3)	= anom1_stats(10)	;upper quartile
   yVals(iYrs,4)	= anom1_stats(26)	;upper 1.0% of data, 99th percentile
   
   ;;;for outliers (as polymarkers on plot)
   minVal(iYrs)	= anom1_stats(2)	;minimum value   
   maxVal(iYrs)	= anom1_stats(14)  	;maximum value

   delete([/data1, anom1, opt, anom1_stats/])
   
  end do	;;end loop TenYrs



  ;***********************************************************
  ;;***********************Plot data**************************
  ;***********************************************************
  
  res			= True
  ;res@gsnFrame		= False			;don't advance frame yet
  res@tiMainString	= "Box plot "+var
  res@trYMinF		= -35
  res@trYMaxF		= 30
  res@tmXBLabels	= TenYrs		;labels for each box
  res@tmXBLabelAngleF	= 90.
  ;res@tmXBLabelDirection= 0			;vertical labels
  res@tmXBLabelFontHeightF = 0.01
  res@tmXBMajorLengthF	= 0.01
  res@gsnMaximize	= True			;maximize box plot in frame
  res@tmEqualizeXYSizes	= True			;all four tickmark axes same font height and tick lengths
  
  opt			= True
  opt@boxWidth		= .85
  
  ;llres			= True			;resources for polylines
  ;llres@gsLineThickness	= 2.5			;line thickness
  
  

  plot = boxplot(wks,xVals,yVals,opt,res,False)
  
  ;;add some polymarkers
  mres			= True			;marker mode desired
  mres@gsMarkerIndex	= 1			;polymarker style circle
  mres@gsMarkerSizeF	= 30.			;polymarker size
  mres@gsMarkerColor	= "black"
  
  minVal_pm		= gsn_add_polymarker(wks,plot,xVals,minVal,mres)
  maxVal_pm		= gsn_add_polymarker(wks,plot,xVals,maxVal,mres)
  
  ;print(minVal)
  		
    
  draw(plot)
  frame(wks)  

end do		;;end loop ClimVars

end
