//
//  MetavoxelSystem.h
//  interface
//
//  Created by Andrzej Kapolka on 12/10/13.
//  Copyright (c) 2013 High Fidelity, Inc. All rights reserved.
//

#ifndef __interface__MetavoxelSystem__
#define __interface__MetavoxelSystem__

#include <QList>
#include <QOpenGLBuffer>
#include <QVector>

#include <glm/glm.hpp>

#include <NodeList.h>

#include <DatagramSequencer.h>
#include <MetavoxelData.h>
#include <MetavoxelMessages.h>

#include "renderer/ProgramObject.h"

/// Renders a metavoxel tree.
class MetavoxelSystem : public QObject {
    Q_OBJECT

public:

    MetavoxelSystem();

    void init();
    
    void applyEdit(const MetavoxelEditMessage& edit);
    
    void simulate(float deltaTime);
    void render();
    
private slots:

    void maybeAttachClient(const SharedNodePointer& node);

private:
    
    class Point {
    public:
        glm::vec4 vertex;
        quint8 color[4];
        quint8 normal[3];
    };
    
    class PointVisitor : public MetavoxelVisitor {
    public:
        PointVisitor(QVector<Point>& points);
        virtual bool visit(MetavoxelInfo& info);
    
    private:
        QVector<Point>& _points;
    };
    
    static ProgramObject _program;
    static int _pointScaleLocation;
    
    QVector<Point> _points;
    PointVisitor _pointVisitor;
    QOpenGLBuffer _buffer;
};

/// A client session associated with a single server.
class MetavoxelClient : public NodeData {
    Q_OBJECT    
    
public:
    
    MetavoxelClient(const SharedNodePointer& node);
    virtual ~MetavoxelClient();

    void applyEdit(const MetavoxelEditMessage& edit);

    void simulate(float deltaTime, MetavoxelVisitor& visitor);

    virtual int parseData(const QByteArray& packet);

private slots:
    
    void sendData(const QByteArray& data);

    void readPacket(Bitstream& in);
    
    void clearReceiveRecordsBefore(int index);
    
private:
    
    void handleMessage(const QVariant& message, Bitstream& in);
    
    class ReceiveRecord {
    public:
        int packetNumber;
        MetavoxelData data;
    };
    
    SharedNodePointer _node;
    
    DatagramSequencer _sequencer;
    
    MetavoxelData _data;
    
    QList<ReceiveRecord> _receiveRecords;
};

#endif /* defined(__interface__MetavoxelSystem__) */
