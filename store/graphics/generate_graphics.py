# Generates the app icon layers and Play Store graphics. Usage: python generate_graphics.py OUTPUT_DIR (needs Pillow)
# Copy icon-1024 / icon-foreground / icon-background into assets/icon/ and run `dart run flutter_launcher_icons`.
import math, sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter
out = sys.argv[1]
TOP=(38,182,255); BOT=(13,94,196)
def gradient(w,h):
    g=Image.new("RGB",(w,h))
    px=g.load()
    for y in range(h):
        t=y/(h-1)
        c=tuple(int(TOP[i]+(BOT[i]-TOP[i])*t) for i in range(3))
        for x in range(w): px[x,y]=c
    return g
def drop_points(cx,cy,r,m=1.6,n=400):
    # teardrop with the point at the top; widest radius r
    pts=[]
    for i in range(n):
        t=2*math.pi*i/n
        x=math.sin(t)*math.sin(t/2)**m
        y=-math.cos(t)
        pts.append((x,y))
    xs=[p[0] for p in pts]; ys=[p[1] for p in pts]
    w=max(xs)-min(xs); h=max(ys)-min(ys)
    s=2*r/w
    my=(max(ys)+min(ys))/2
    return [(cx+x*s, cy+(y-my)*s) for x,y in pts], h*s
def star_points(cx,cy,R,r,n=5):
    pts=[]
    for i in range(2*n):
        a=-math.pi/2+i*math.pi/n
        rr=R if i%2==0 else r
        pts.append((cx+rr*math.cos(a), cy+rr*math.sin(a)))
    return pts
def draw_mark(img, cx, cy, r, drop=(255,255,255), star=None):
    star = star or BOT
    d=ImageDraw.Draw(img)
    pts,h=drop_points(cx,cy,r)
    d.polygon(pts, fill=drop)
    # star sits in the round lower part of the drop
    sy=cy+h*0.14
    d.polygon(star_points(cx,sy,r*0.52,r*0.22), fill=star)

SS=4
# 512 Play Store icon (full bleed square; Play applies its own rounding)
N=512*SS
icon=gradient(N,N)
draw_mark(icon,N/2,N/2,N*0.27)
icon.resize((512,512),Image.LANCZOS).save(f"{out}/icon-512.png")
# 1024 master for flutter_launcher_icons (legacy icon)
icon.resize((1024,1024),Image.LANCZOS).save(f"{out}/icon-1024.png")
# Adaptive icon: foreground on transparent, mark inside the 66% safe zone; background solid gradient
fg=Image.new("RGBA",(N,N),(0,0,0,0))
draw_mark(fg,N/2,N/2,N*0.19)
fg.resize((1024,1024),Image.LANCZOS).save(f"{out}/icon-foreground.png")
gradient(1024,1024).save(f"{out}/icon-background.png")
# Feature graphic 1024x500
W,H=1024*SS,500*SS
fgimg=gradient(W,H)
draw_mark(fgimg,W*0.2,H*0.5,H*0.28)
d=ImageDraw.Draw(fgimg)
try:
    big=ImageFont.truetype("DejaVuSans-Bold.ttf",int(H*0.22)); small=ImageFont.truetype("DejaVuSans.ttf",int(H*0.085))
except OSError:
    big=small=ImageFont.load_default()
d.text((W*0.37,H*0.25),"hydRate",font=big,fill="white")
d.text((W*0.37,H*0.56),"Find & rate water fountains",font=small,fill=(230,244,255))
d.text((W*0.37,H*0.69),"and bathrooms near you",font=small,fill=(230,244,255))
fgimg.resize((1024,500),Image.LANCZOS).save(f"{out}/feature-graphic.png")
print("ok")
