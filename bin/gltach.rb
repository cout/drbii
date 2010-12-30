require 'opengl'
require 'mathn'
include Gl,Glu,Glut

require 'drbii/drbii'
require 'drbii/io/ftdi_io'
require 'drbii/memory_map'

class GlutApplication
  def initialize
    glutInit()
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH)
    glutCreateWindow($0)
    glutFullScreen()
    glutDisplayFunc(self.method(:display).to_proc) 
    glutReshapeFunc(self.method(:reshape).to_proc)
    glutKeyboardFunc(self.method(:keyboard).to_proc)
    glutIdleFunc(self.method(:idle).to_proc)
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

  def idle
  end

  def with_matrix
    glPushMatrix()
    begin
      yield
    ensure
      glPopMatrix()
    end
  end

  def gl_do(x)
    glBegin(x)
    begin
      yield
    ensure
      glEnd()
    end
  end
end

class Tachometer < GlutApplication
  def initialize
    super()

    @rpms = 0

    setup_graphics()
    start_reader_thread()
  end

  def start_reader_thread
    source_filename = ARGV[0]
    mmap = MemoryMap.new(source_filename)

    ftdi_dev = ARGV[1]
    ftdi = FtdiIO.new(ftdi_dev, true)

    drbii = DRBII.new(ftdi)
    drbii.handshake()

    rpm_loc = mmap['RPM']

    Thread.new do
      Thread.current.abort_on_exception = true
      @rpms = rpm_loc.read(drbii)
    end
  end

  def setup_graphics
    glEnable(GL_LIGHTING)
    glEnable(GL_LIGHT0)
    glEnable(GL_DEPTH_TEST)
    
    @lists = glGenLists(1)
    qobj = gluNewQuadric()
    
    gluQuadricDrawStyle(qobj, GLU_LINE)
    gluQuadricNormals(qobj, GLU_NONE)

    glNewList(@lists, GL_COMPILE)
    gluDisk(qobj, 0.9, 1.0, 20, 1)

    (0..8).each do |krpms|
      label = "#{krpms}"
      radians = rpms_to_radians(krpms * 1000)
      with_matrix do
        glTranslate(1.2 * Math.cos(radians), 1.2 * Math.sin(radians), 0)
        glScale(0.001, 0.001, 1)
        label.each_byte { |x| glutStrokeCharacter(GLUT_STROKE_ROMAN, x) }
      end
    end

    glEndList()
  end

  def degrees_to_radians(degrees)
    radians = 2 * Math::PI * (degrees / 360.0)
    return radians
  end

  def rpms_to_degrees(rpms)
    zero = 216.0
    step = 36.0
    return zero - (rpms / 1000.0) * step
  end

  def rpms_to_radians(rpms)
    degrees = rpms_to_degrees(rpms)
    radians = degrees_to_radians(degrees)
    return radians
  end

  def display
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    
    with_matrix do
      glTranslate(-1.0, -1.0, 0.0)
      glCallList(@lists)

      rpms = 6500
      radians = rpms_to_radians(rpms)
      gl_do(GL_LINES) do
        glVertex(0, 0)
        glVertex(0.7 * Math.cos(radians), 0.7 * Math.sin(radians))
      end
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

