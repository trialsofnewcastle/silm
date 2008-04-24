/*
 * $Id: GffXmlWriter.java,v 1.7 2007/09/03 18:57:51 pspeed Exp $
 *
 * Copyright (c) 2004, Paul Speed
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1) Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2) Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3) Neither the names "Progeeks", "Meta-JB", nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

package org.progeeks.nwn.io.xml;

import java.io.*;
import java.util.*;

import org.progeeks.meta.xml.*;
import org.progeeks.util.xml.*;

import org.progeeks.nwn.gff.*;

/**
 *  This writes Gff elements as XML tags.  This is not a
 *  standard Writer implementation.
 *
 *  @version   $Revision: 1.7 $
 *  @author    Paul Speed
 */
public class GffXmlWriter
{
    private String name;
    private String type;
    private String version;
    private XmlPrintWriter out;

    public GffXmlWriter( String resourceName, String type, String version, Writer out )
    {
        this.name = resourceName;
        this.type = type;
        this.version = version;
        this.out = new XmlPrintWriter( out );

        init();
    }

    protected void init()
    {
        out.pushTag( "gff" );
        out.printAttribute( "name", name );
        out.printAttribute( "type", type );
        out.printAttribute( "version", version );
    }

    public void writeStruct( Struct struct )
    {
        out.pushTag( "struct" );
        out.printAttribute( "id", String.valueOf( struct.getId() ) );

        writeElements( struct.getValues() );

        out.popTag();
    }

    protected void writeElements( List elements )
    {
        for( Iterator it = elements.iterator(); it.hasNext(); )
            {
            Object obj = it.next();
            if( obj instanceof Element )
                writeElement( (Element)obj );
            else if( obj instanceof Struct )
                writeStruct( (Struct)obj );
            else
                System.out.println( "Unknown object type: " + obj );
            }
    }

    protected void writeElement( Element el )
    {
        out.pushTag( "element" );
        out.printAttribute( "name", el.getName() );
        out.printAttribute( "type", String.valueOf( el.getType() ) );

        if( el instanceof StructElement )
            {
            StructElement se = (StructElement)el;
            writeStruct( se.getStruct() );
            }
        else if( el instanceof ListElement )
            {
            ListElement ll = (ListElement)el;
            writeElements( ll.getValue() );
            }
        else if( el instanceof StringElement )
            {
            StringElement se = (StringElement)el;
            String val = se.getValue();
            // no attribute means no value
            if( val != null )
                {
                if( val.indexOf( '\r' ) < 0 && val.indexOf( '\n' ) < 0 )
                    {
                    out.printAttribute( "value", val );
                    }
                else
                    {
                    out.pushTag( "value" );
                    out.startDataBlock();
                    out.print( val );
                    out.closeDataBlock();
                    out.popTag();
                    }
                }
            }
        else if( el instanceof LocalizedStringElement )
            {
            LocalizedStringElement se = (LocalizedStringElement)el;

            out.printAttribute( "value", String.valueOf( se.getReferenceId() ) );

            for( Iterator i = se.getLocalStrings().entrySet().iterator(); i.hasNext(); )
                {
                Map.Entry e = (Map.Entry)i.next();
                out.pushTag( "localString" );
                out.printAttribute( "languageId", e.getKey().toString() );
                String val = (String)e.getValue();
                if( val.indexOf( '\r' ) < 0 && val.indexOf( '\n' ) < 0 )
                    {
                    out.printAttribute( "value", val );
                    }
                else
                    {
                    out.pushTag( "value" );
                    out.startDataBlock();
                    out.print( val );
                    out.closeDataBlock();
                    out.popTag();
                    }
                out.popTag();
                }
            }
        else
            {
            out.printAttribute( "value", el.getStringValue() );
            }

        out.popTag();
    }

    public void close()
    {
        out.popTag();
        out.close();
    }
}