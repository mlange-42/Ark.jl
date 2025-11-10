using GLMakie

size = (800, 600)

GLMakie.activate!(renderloop=GLMakie.renderloop)

scene = GLMakie.Scene(size=size, camera=campixel!)
screen = display(scene)

img_data = rand(UInt8, size...)
img_node = Observable(img_data)
image!(scene, img_node)

GLMakie.renderloop(screen)
