class NodeVisitor
  def visit(node)
    send("visit_#{node.class.name}", node)
  end
end
