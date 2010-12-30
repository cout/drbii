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

  def compile_list(list = glGenLists(1))
    glNewList(list, GL_COMPILE)
    begin
      yield
    ensure
      glEndList()
    end
    return list
  end
end

class Tachometer < GlutApplication
  def initialize
    super()

    @rpms = 0
    setup_graphics()
    start_dummy_thread
    # start_reader_thread()
  end

  def start_dummy_thread()
    Thread.new do
      Thread.current.abort_on_exception = true
      loop do
        sleep 1
        s = Time.now
        base = @rpms
        while @rpms < 6500 do
          t = Time.now
          @rpms = [ 6500, (t - s) * 2 * 6500 ].min
          @rpms = [ base, @rpms ].max
          glutPostRedisplay()
          Thread.pass
        end
        s = Time.now
        while @rpms > 800 do
          t = Time.now
          @rpms = [ 800, 6500 - (t - s) * 5000 ].max
          glutPostRedisplay()
          Thread.pass
        end
      end
    end
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

  def enable_antialiasing
    glEnable(GL_LINE_SMOOTH)
    glEnable(GL_BLEND)
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
    glHint(GL_LINE_SMOOTH_HINT, GL_DONT_CARE)
    glLineWidth(1.5)
  end

  def setup_graphics
    enable_antialiasing()

    # glEnable(GL_LIGHTING)
    glDisable(GL_LIGHTING)
    # glEnable(GL_LIGHT0)
    #glEnable(GL_DEPTH_TEST)
    
    @tach = compile_tach()
    @needle = compile_needle()
  end

  def compile_needle
    return compile_list do
      glColor(0.2, 0.2, 0.6)
      gl_do(GL_POLYGON) do
        glVertex(-0.01, 0)
        glVertex(0.01, 0)
        glVertex(0, 0.7)
      end

      # Draw a highlight - TODO: use lighting effects for this
      glColor(0.6, 0.6, 1.0)
      gl_do(GL_LINES) do
        glVertex(0, 0)
        glVertex(0, 0.7)
      end
    end
  end

  def compile_tach
    qobj = gluNewQuadric()
    
    return compile_list do
      glColor(0.5, 0.0, 0.0)
      gluQuadricDrawStyle(qobj, GLU_FILL)
      gluQuadricNormals(qobj, GLU_NONE)
      gluPartialDisk(qobj, 0.9, 1.0, 2, 1, 90-18, 36) # overdraw this one, since gluPartialDisk won't draw less than 2 pieces

      glColor(1.0, 0.0, 0.0)
      gluQuadricDrawStyle(qobj, GLU_FILL)
      gluQuadricNormals(qobj, GLU_NONE)
      gluPartialDisk(qobj, 0.9, 1.0, 4, 1, 90, 72)

      glColor(1.0, 1.0, 1.0)
      gluQuadricDrawStyle(qobj, GLU_LINE)
      gluQuadricNormals(qobj, GLU_NONE)
      gluDisk(qobj, 0.9, 1.0, 20, 1)

      glColor(0.2, 1.0, 0.8)
      (0..8).each do |krpms|
        label = "#{krpms}"
        radians = rpms_to_radians(krpms * 1000)
        with_matrix do
          glTranslate(1.2 * Math.cos(radians), 1.2 * Math.sin(radians), 0)
          glScale(0.001, 0.001, 1)
          label.each_byte { |x| glutStrokeCharacter(GLUT_STROKE_ROMAN, x) }
        end
      end
    end
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

  def draw_tach
    glCallList(@tach)
  end

  def draw_needle
    degrees = rpms_to_degrees(@rpms)
    with_matrix do
      glRotate(degrees - 90, 0, 0, 1)
      glCallList(@needle)
    end
  end

  def display
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    
    with_matrix do
      draw_tach()
      draw_needle()
    end

    glutSwapBuffers()
  end

  def reshape(w, h)
    s = 1.5
    glViewport(0, 0,  w,  h)
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
    r1 = w > h ? w.to_f/h : 1.0
    r2 = w > h ? 1.0 : (h.to_f/w)
    glOrtho(-s*r1, s*r1, -s*r2, s*r2, -10.0, 10.0)
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

