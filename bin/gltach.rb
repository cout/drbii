require 'opengl'
require 'mathn'
include Gl,Glu,Glut

class GlutApplication
  def initialize
    glutInit()
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH)
    glutCreateWindow($0)
    glutFullScreen()
    glutDisplayFunc(self.method(:display).to_proc) 
    glutReshapeFunc(self.method(:reshape).to_proc)
    glutKeyboardFunc(self.method(:keyboard).to_proc)
  end

  def run
    glutMainLoop()
  end

  def init
  end

  def display
  end

  def reshape(w, h)
  end

  def keyboard(key, x, y)
  end

  def with_matrix
    glPushMatrix()
    begin
      yield
    ensure
      glPopMatrix()
    end
  end
end

class Tachometer < GlutApplication
  def initialize
    super()

    glEnable(GL_LIGHTING)
    glEnable(GL_LIGHT0)
    glEnable(GL_DEPTH_TEST)
    
    @lists = glGenLists(1)
    qobj = gluNewQuadric()
    
    gluQuadricDrawStyle(qobj, GLU_LINE)
    gluQuadricNormals(qobj, GLU_NONE)
    glNewList(@lists, GL_COMPILE)
    gluDisk(qobj, 0.9, 1.0, 20, 1)
    glEndList()
  end

  def display
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    
    with_matrix do
      glTranslate(-1.0, -1.0, 0.0)
      glCallList(@lists)
    end

    glutSwapBuffers()
  end

  def reshape(w, h)
    glViewport(0, 0,  w,  h)
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
    if (w <= h)
      glOrtho(-2.5, 2.5, -2.5*h/w, 2.5*h/w, -10.0, 10.0)
    else
      glOrtho(-2.5*w/h, 2.5*w/h, -2.5, 2.5, -10.0, 10.0)
    end
    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity()
  end

  def keyboard(key, x, y)
    exit if key == ?\e
  end
end

if __FILE__ == $0 then
  tach = Tachometer.new
  tach.run
end

