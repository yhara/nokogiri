
TARGET        = libprimitives
DLLIB         = $(TARGET).so
OBJS          = primitives_support.o

CLEANOBJS     = *.o *.a *.s[ol] *.pdb *.exp *.bak
CLEANLIBS     = $(TARGET).so $(TARGET).il? $(TARGET).tds $(TARGET).map

libprimitives.so: $(OBJS)
	gcc -shared -o $@ $(OBJS)

clean:
	$(RM) $(CLEANLIBS) $(CLEANOBJS)
