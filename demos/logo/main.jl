using GLMakie

GLMakie.activate!(renderloop=GLMakie.renderloop)

scene = GLMakie.Scene(size=(800, 600))
screen = display(scene)

GLMakie.renderloop(screen)
